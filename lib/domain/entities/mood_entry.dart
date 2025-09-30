// lib/domain/entities/mood_entry.dart

class MoodEntry {
  final String id;
  final DateTime date; // normalisé à minuit UTC
  final String emotion;
  final int intensity;
  final String? note;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodEntry({
    required this.id,
    required this.date,
    required this.emotion,
    required this.intensity,
    required this.note,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    String? emotion,
    int? intensity,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}