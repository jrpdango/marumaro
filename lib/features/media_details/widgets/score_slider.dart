import 'package:flutter/material.dart';

/// A 0-10 score slider, shared by the edit form and the quick-edit score sheet.
class ScoreSlider extends StatelessWidget {
  const ScoreSlider({super.key, required this.score, required this.onChanged});

  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: score.toDouble(),
      min: 0,
      max: 10,
      divisions: 10,
      label: "$score",
      onChanged: (double value) => onChanged(value.round()),
    );
  }
}
