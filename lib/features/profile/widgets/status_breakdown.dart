import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';

/// A donut chart of list statuses with a legend beside it.
class StatusBreakdown extends StatelessWidget {
  const StatusBreakdown({super.key, required this.stats});

  final MediaStats stats;

  /// The color used for a status slice, shared by the chart and its legend.
  static Color colorFor(ColorScheme scheme, String status) {
    switch (status) {
      case "watching":
      case "reading":
        return scheme.primary;
      case "completed":
        return scheme.secondary;
      case "on_hold":
        return scheme.tertiary;
      case "dropped":
        return scheme.error;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    if (stats.total == 0) {
      return Text(
        "Nothing here yet.",
        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 128.0,
          height: 128.0,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PieChart(
                PieChartData(
                  sectionsSpace: 3.0,
                  centerSpaceRadius: 36.0,
                  borderData: FlBorderData(show: false),
                  sections: <PieChartSectionData>[
                    for (final StatusCount entry in stats.statuses)
                      PieChartSectionData(
                        value: entry.count.toDouble(),
                        color: colorFor(scheme, entry.status),
                        radius: 20.0,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("${stats.total}", style: text.titleLarge),
                  Text(
                    "titles",
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTokens.spaceLg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final StatusCount entry in stats.statuses)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.spaceXs / 2,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          color: colorFor(scheme, entry.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTokens.spaceSm),
                      Expanded(
                        child: Text(
                          entry.label,
                          style: text.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${entry.count}",
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
