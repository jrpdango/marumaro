import 'package:flutter/material.dart';
import 'package:tamarun/core/theme/app_colors.dart';

/// A titled content section: the title, a gap, then [child].
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTokens.spaceMd),
        child,
      ],
    );
  }
}
