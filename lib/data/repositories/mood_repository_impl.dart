// lib/data/repositories/mood_repository_impl.dart

import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';

import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/mood_entry.dart' as domain;
import '../../domain/repositories/mood_repository.dart';
import '../local/db.dart';

class MoodRepositoryImpl implements MoodRepository {
  final AppDatabase db;
  MoodRepositoryImpl(this.db);

  static final _uuid = Uuid();

  int _midnightUtcMs(DateTime dttm) {
    final dt = DateTime.utc(dttm.year, dttm.month, dttm.day);
    return dt.millisecondsSinceEpoch;
  }

  @override
  Future<void> upsertEntry(domain.MoodEntry entry) async {
    final id = entry.id.isEmpty ? _uuid.v4() : entry.id;
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    final tagsJson = jsonEncode(entry.tags);
    await db.upsertMood(MoodEntriesCompanion(
      id: d.Value(id),
      date: d.Value(_midnightUtcMs(entry.date)),
      emotion: d.Value(entry.emotion),
      intensity: d.Value(entry.intensity),
      note: d.Value(entry.note),
      // correspond au nom de la colonne dans la table
      tagsJsonRaw: d.Value(tagsJson),
      createdAt: d.Value(
          entry.createdAt.millisecondsSinceEpoch == 0 ? nowMs : entry.createdAt.millisecondsSinceEpoch),
      updatedAt: d.Value(nowMs),
      deleted: const d.Value(false),
    ));
  }

  @override
  Future<domain.MoodEntry?> getEntryForDay(DateTime dayUtc) async {
    final result = await db.getMoodForDay(_midnightUtcMs(dayUtc.toUtc()));
    if (result == null) return null;
    // Conversion Drift -> domaine si besoin
    return domain.MoodEntry(
      id: result.id,
      date: DateTime.fromMillisecondsSinceEpoch(result.date, isUtc: true),
      emotion: result.emotion,
      intensity: result.intensity,
      note: result.note,
      tags: (jsonDecode(result.tagsJsonRaw) as List).map((e) => e.toString()).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(result.createdAt, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(result.updatedAt, isUtc: true),
    );
  }

  @override
  Future<List<domain.MoodEntry>> getEntriesInRange(DateTime startUtc, DateTime endUtc) async {
    final results = await db.getMoodsInRange(
      _midnightUtcMs(startUtc.toUtc()),
      _midnightUtcMs(endUtc.toUtc()),
    );
    return results.map((result) => domain.MoodEntry(
      id: result.id,
      date: DateTime.fromMillisecondsSinceEpoch(result.date, isUtc: true),
      emotion: result.emotion,
      intensity: result.intensity,
      note: result.note,
      tags: (jsonDecode(result.tagsJsonRaw) as List).map((e) => e.toString()).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(result.createdAt, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(result.updatedAt, isUtc: true),
    )).toList();
  }

  @override
  Future<void> deleteEntry(String id) => db.softDelete(id);
}