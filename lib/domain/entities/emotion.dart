import 'package:flutter/material.dart';

class Emotion {
  final String key;
  final String label;
  final String emoji;
  final Color color;
  final bool isActive;

  const Emotion({
    required this.key,
    required this.label,
    required this.emoji,
    required this.color,
    this.isActive = true,
  });
}