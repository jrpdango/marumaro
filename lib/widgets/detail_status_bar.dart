import 'package:flutter/material.dart';
import 'package:miru/constants.dart';

class DetailStatusBar extends StatelessWidget {
  final List<Widget>? children;

  const DetailStatusBar({
    Key? key,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 64.0),
      color: MiruColors.tabBarBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children ?? <Widget>[],
      ),
    );
  }
}
