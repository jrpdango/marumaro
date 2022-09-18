import 'package:flutter/material.dart';

const Color _textColor = Color(0xFFFDFFFF);
const Color _unselectedItemColor = Color(0xFFBBBDBD);
const Color _tabBarIndicatorColor = Color(0xFF21E9FF);
const Color _tabBarBackgroundColor = Color(0xFF1C1C1C);

ThemeData themeData = ThemeData.dark().copyWith(
  textTheme: Typography().white,
  tabBarTheme: const TabBarTheme(
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        width: 2.0,
        color: _tabBarIndicatorColor,
      ),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _tabBarBackgroundColor,
    selectedItemColor: _textColor,
    unselectedItemColor: _unselectedItemColor,
  ),
);
