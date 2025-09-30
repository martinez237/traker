import 'package:flutter/material.dart';

class EmotionPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const EmotionPicker({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = _defaultEmotions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Émotion', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((e) {
            final sel = selected == e.key;
            return ChoiceChip(
              label: Text('${e.emoji} ${e.label}'),
              selected: sel,
              onSelected: (_) => onSelect(e.key),
              selectedColor: e.color.withOpacity(0.2),
              labelStyle: TextStyle(
                color: sel ? e.color : null,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(color: e.color),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EmotionItem {
  final String key;
  final String label;
  final String emoji;
  final Color color;
  const _EmotionItem(this.key, this.label, this.emoji, this.color);
}

List<_EmotionItem> _defaultEmotions() => const [
  _EmotionItem('happy', 'Heureux', '😄', Color(0xFF4CAF50)),
  _EmotionItem('calm', 'Calme', '😌', Color(0xFF90CAF9)),
  _EmotionItem('energetic', 'Énergique', '⚡', Color(0xFFFFD54F)),
  _EmotionItem('stressed', 'Stressé', '😣', Color(0xFFFF7043)),
  _EmotionItem('sad', 'Triste', '😢', Color(0xFF64B5F6)),
  _EmotionItem('tired', 'Fatigué', '😴', Color(0xFFA1887F)),
  _EmotionItem('anxious', 'Anxieux', '😬', Color(0xFFEF5350)),
];