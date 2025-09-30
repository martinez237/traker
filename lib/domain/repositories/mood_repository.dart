// lib/domain/repositories/mood_repository.dart

import '../entities/mood_entry.dart';

abstract class MoodRepository {
  Future<void> upsertEntry(MoodEntry entry);
  Future<MoodEntry?> getEntryForDay(DateTime dayUtc);
  Future<List<MoodEntry>> getEntriesInRange(DateTime startUtc, DateTime endUtc);
  Future<void> deleteEntry(String id);
}