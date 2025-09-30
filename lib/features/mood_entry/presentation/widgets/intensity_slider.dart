import 'package:flutter/material.dart';

class IntensitySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const IntensitySlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Intensité', style: TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            const Text('1 😕'),
            Expanded(
              child: Slider(
                value: value,
                min: 1,
                max: 5,
                divisions: 4,
                label: value.round().toString(),
                onChanged: onChanged,
              ),
            ),
            const Text('5 🤩'),
          ],
        ),
      ],
    );
  }
}