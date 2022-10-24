import 'package:flutter/material.dart';
import 'package:miru/constants.dart' show MiruColors;

class BaseOverlay extends StatelessWidget {
  final Widget child;
  const BaseOverlay({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: MiruColors.cardColor,
        ),
        constraints: const BoxConstraints(
          maxWidth: 320.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: child,
      ),
    );
  }
}
