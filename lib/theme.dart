import 'package:flutter/material.dart';

const Color _textColor = Color(0xFFFDFFFF);
const Color _unselectedItemColor = Color(0xFFBBBDBD);
const Color _tabBarIndicatorColor = Color(0xFF21E9FF);
const Color _tabBarBackgroundColor = Color(0xFF1C1C1C);
const Color _backgroundColor = Color(0xFF212121);
const Color _cardColor = Color(0xFF262626);

ThemeData themeData = ThemeData.dark().copyWith(
  cardColor: _cardColor,
  scaffoldBackgroundColor: _backgroundColor,
  drawerTheme: const DrawerThemeData().copyWith(
    backgroundColor: _backgroundColor,
  ),
  textTheme: Typography().white,
  tabBarTheme: const TabBarTheme(
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        width: 2.0,
        color: _tabBarIndicatorColor,
      ),
    ),
  ),
  // TODO: Edit selectedlabelstyle
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _tabBarBackgroundColor,
    selectedItemColor: _textColor,
    unselectedItemColor: _unselectedItemColor,
  ),
);
