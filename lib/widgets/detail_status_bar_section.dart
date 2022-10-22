import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class DetailStatusBarSection extends StatelessWidget {
  final IconData icon;
  final String text;

  const DetailStatusBarSection({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon),
        Text(text),
      ],
    );
  }
}
