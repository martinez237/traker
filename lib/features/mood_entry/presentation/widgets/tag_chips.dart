import 'package:flutter/material.dart';

class TagChips extends StatefulWidget {
  final List<String> initial;
  final void Function(String tag, bool on) onToggle;
  const TagChips({super.key, required this.initial, required this.onToggle});

  @override
  State<TagChips> createState() => _TagChipsState();
}

class _TagChipsState extends State<TagChips> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in widget.initial)
              FilterChip(
                label: Text(tag),
                selected: _selected.contains(tag),
                onSelected: (on) {
                  setState(() {
                    if (on) {
                      _selected.add(tag);
                    } else {
                      _selected.remove(tag);
                    }
                  });
                  widget.onToggle(tag, on);
                },
              ),
          ],
        ),
      ],
    );
  }
}