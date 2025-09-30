class UserSettings {
  final bool reminderEnabled;
  final TimeOfDay? reminderTime;
  final String theme; // system|light|dark

  const UserSettings({
    required this.reminderEnabled,
    required this.reminderTime,
    required this.theme,
  });

  UserSettings copyWith({
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
    String? theme,
  }) {
    return UserSettings(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      theme: theme ?? this.theme,
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;
  const TimeOfDay({required this.hour, required this.minute});
}