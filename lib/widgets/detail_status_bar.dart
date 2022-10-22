import 'package:flutter/material.dart';
import 'package:miru/constants.dart';
import 'package:miru/widgets/detail_status_bar_section.dart';

class DetailStatusBar extends StatelessWidget {
  const DetailStatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 64.0),
      color: MiruColors.tabBarBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DetailStatusBarSection(
            icon: Icons.movie_rounded,
            text: 'Watching',
            onTap: () {},
          ),
          DetailStatusBarSection(
            icon: Icons.remove_red_eye,
            text: '2/12',
            onTap: () {},
          ),
          DetailStatusBarSection(
            icon: Icons.star,
            text: '0',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
