import 'package:flutter/material.dart';
import 'package:miru/constants.dart';

class DetailStatusBar extends StatelessWidget {
  const DetailStatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 80.0),
      color: MiruColors.tabBarBackgroundColor,
      child: Row(
        children: <Widget>[],
      ),
    );
  }
}
