import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:miru/widgets/detail_status_bar_section.dart';

class DetailStatusBar extends StatelessWidget {
  const DetailStatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.0,
      child: Row(
        children: <Widget>[
          DetailStatusBarSection(icon: Icons.movie_rounded, text: 'Watching')
        ],
      ),
    );
  }
}
