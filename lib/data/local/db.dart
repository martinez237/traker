// lib/data/local/db.dart

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// On importe seulement le type de domaine pour le mapping
import '../../domain/entities/mood_entry.dart' show MoodEntry;

part 'db.g.dart';

class MoodEntries extends Table {
  TextColumn get id => text()();
  IntColumn get date => integer()(); // UTC millis (minuit)
  TextColumn get emotion => text()();
  IntColumn get intensity => integer()();
  TextColumn get note => text().nullable()();

  // Stockage JSON texte
  TextColumn get tagsJsonRaw => text().withDefault(const Constant('[]'))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [MoodEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  int get schemaVersion => 1;

  Future<void> upsertMood(MoodEntriesCompanion entry) async {
    await into(moodEntries).insertOnConflictUpdate(entry);
  }

  Future<MoodEntry?> getMoodForDay(int dayUtcMs) async {
    final row = await (select(moodEntries)
      ..where((t) => t.date.equals(dayUtcMs) & t.deleted.equals(false)))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapRow(row);
  }

  Future<List<MoodEntry>> getMoodsInRange(int startMs, int endMs) async {
    final rows = await (select(moodEntries)
      ..where((t) =>
      t.date.isBiggerOrEqualValue(startMs) &
      t.date.isSmallerOrEqualValue(endMs) &
      t.deleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return rows.map(_mapRow).toList();
  }

  Future<void> softDelete(String id) async {
    await (update(moodEntries)..where((t) => t.id.equals(id)))
        .write(const MoodEntriesCompanion(deleted: Value(true)));
  }

  MoodEntry _mapRow(MoodEntry r) {
    return r;
  }
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'app.db'));
    return SqfliteQueryExecutor(path: dbFile.path, logStatements: false);
  });
}