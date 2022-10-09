import 'package:flutter/material.dart';
import 'package:miru/constants.dart' show MiruColors;

ThemeData themeData = ThemeData.dark().copyWith(
  dialogBackgroundColor: MiruColors.backgroundColor,
  cardColor: MiruColors.cardColor,
  scaffoldBackgroundColor: MiruColors.backgroundColor,
  drawerTheme: const DrawerThemeData().copyWith(
    backgroundColor: MiruColors.backgroundColor,
  ),
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Rubik'),
  tabBarTheme: const TabBarTheme(
    labelPadding: EdgeInsets.symmetric(horizontal: 15.0),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        width: 2.0,
        color: MiruColors.primaryColor,
      ),
    ),
  ),
  // TODO: Edit selectedlabelstyle
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: MiruColors.tabBarBackgroundColor,
    selectedItemColor: MiruColors.textColor,
    unselectedItemColor: MiruColors.unselectedItemColor,
  ),
);
