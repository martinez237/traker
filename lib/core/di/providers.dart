import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/db.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../domain/repositories/mood_repository.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final moodRepositoryProvider = Provider<MoodRepository>(
      (ref) => MoodRepositoryImpl(ref.watch(dbProvider)),
);