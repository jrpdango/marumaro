import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';

/// A bar chart of the user's score distribution (1-10) with a toggle between
/// anime and manga, plus the mean and median for the selected kind.
class ScoreDistribution extends StatefulWidget {
  const ScoreDistribution({
    super.key,
    required this.anime,
    required this.manga,
  });

  final MediaStats anime;
  final MediaStats manga;

  @override
  State<ScoreDistribution> createState() => _ScoreDistributionState();
}

class _ScoreDistributionState extends State<ScoreDistribution> {
  MediaKind _kind = MediaKind.anime;

  MediaStats get _stats =>
      _kind == MediaKind.anime ? widget.anime : widget.manga;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final MediaStats stats = _stats;
    final int maxCount = stats.scoreHistogram.fold<int>(
      0,
      (int max, int count) => count > max ? count : max,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SegmentedButton<MediaKind>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<MediaKind>>[
                  ButtonSegment<MediaKind>(
                    value: MediaKind.anime,
                    label: Text("Anime"),
                  ),
                  ButtonSegment<MediaKind>(
                    value: MediaKind.manga,
                    label: Text("Manga"),
                  ),
                ],
                selected: <MediaKind>{_kind},
                onSelectionChanged: (Set<MediaKind> selection) =>
                    setState(() => _kind = selection.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.spaceMd),
        if (!stats.hasScores)
          Text(
            "No scores yet.",
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          )
        else ...<Widget>[
          Row(
            children: <Widget>[
              _Summary(label: "Scored", value: "${stats.scoredCount}"),
              const SizedBox(width: AppTokens.spaceLg),
              _Summary(
                label: "Mean",
                value: stats.meanScore.toStringAsFixed(2),
              ),
              const SizedBox(width: AppTokens.spaceLg),
              _Summary(
                label: "Median",
                value: stats.medianScore.toStringAsFixed(1),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          SizedBox(
            height: 160.0,
            child: BarChart(
              BarChartData(
                maxY: (maxCount == 0 ? 1 : maxCount).toDouble(),
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24.0,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int score = value.toInt();
                        if (score < 1 || score > 10) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppTokens.spaceXs),
                          child: Text(
                            "$score",
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: <BarChartGroupData>[
                  for (int i = 0; i < stats.scoreHistogram.length; i++)
                    BarChartGroupData(
                      x: i + 1,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: stats.scoreHistogram[i].toDouble(),
                          width: 12.0,
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(
                            AppTokens.radiusSm / 2,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Text(value, style: text.titleSmall),
      ],
    );
  }
}
