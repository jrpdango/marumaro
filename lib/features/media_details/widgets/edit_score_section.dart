part of '../edit_list_page.dart';

/// The score section: the current value and a 0-10 slider.
class _ScoreSection extends StatelessWidget {
  const _ScoreSection({required this.score, required this.onChanged});

  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _EditSection(
      title: "Score",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Spacer(),
              Text("$score", style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          ScoreSlider(score: score, onChanged: onChanged),
        ],
      ),
    );
  }
}
