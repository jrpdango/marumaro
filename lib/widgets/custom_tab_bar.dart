import 'package:flutter/material.dart';

class CustomTabBar extends Container implements PreferredSizeWidget {
  CustomTabBar({Key? key, Color? color, this.tabBar})
      : super(key: key, color: color);

  final TabBar? tabBar;

  @override
  Size get preferredSize => tabBar!.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        color: color,
        child: tabBar,
      );
}
