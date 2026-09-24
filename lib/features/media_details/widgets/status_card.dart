part of 'media_details_view.dart';

/// The quick-edit card holding the tappable status/score stats and the
/// progress stepper.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.inList,
    required this.statusLabel,
    required this.score,
    required this.progress,
    required this.progressTotal,
    required this.progressLabel,
    required this.onStatusTap,
    required this.onScoreTap,
    required this.onProgressDelta,
    this.onProgressTap,
  });

  final bool inList;
  final String statusLabel;
  final int score;
  final int progress;
  final int progressTotal;
  final String progressLabel;
  final VoidCallback onStatusTap;
  final VoidCallback onScoreTap;
  final ValueChanged<int> onProgressDelta;
  final VoidCallback? onProgressTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _TappableStat(
                      label: "Status",
                      value: inList ? statusLabel : "Add to list",
                      onTap: onStatusTap,
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceSm),
                  Expanded(
                    child: _TappableStat(
                      label: "Score",
                      value: "$score",
                      icon: Icons.star_rounded,
                      onTap: onScoreTap,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceSm),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => onProgressDelta(-1),
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: "Decrease $progressLabel",
                ),
                Expanded(
                  child: _ProgressStat(
                    label: progressLabel,
                    value: progress,
                    total: progressTotal,
                    onTap: onProgressTap,
                  ),
                ),
                IconButton(
                  onPressed: () => onProgressDelta(1),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: "Increase $progressLabel",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
