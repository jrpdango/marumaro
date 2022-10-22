import 'package:flutter/material.dart';
import 'package:miru/constants.dart';

class DetailStatusBarSection extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onTap;

  const DetailStatusBarSection({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: MiruColors.tabBarBackgroundColor,
        child: InkWell(
          onTap: () => onTap.call(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
