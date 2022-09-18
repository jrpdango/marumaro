import 'package:flutter/material.dart';

const Color _textColor = Color(0xFFFDFFFF);
const Color _unselectedItemColor = Color(0xFFBBBDBD);

ThemeData themeData = ThemeData.dark().copyWith(
  textTheme: Typography().white,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: _textColor,
    unselectedItemColor: _unselectedItemColor,
  ),
);
