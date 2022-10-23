import 'package:flutter/material.dart' show Color;

/// Limit of how many list items can be retrieved in one call.
const int limitOfListItems = 300;

/// MAL API URL for generating or refreshing token pairs.
const String apiTokenUrl = 'https://myanimelist.net/v1/oauth2/token';

/// Contains custom colors for the app.
class MiruColors {
  static const Color primaryColor = Color(0xFF21E9FF);
  static const Color primaryVariant = Color(0xFF1ECDE0);
  static const Color textColor = Color(0xFFFDFFFF);
  static const Color unselectedItemColor = Color(0xFFBBBDBD);
  static const Color tabBarBackgroundColor = Color(0xFF1C1C1C);
  static const Color backgroundColor = Color(0xFF212121);
  static const Color cardColor = Color(0xFF2E2E2E);
  static const Color buttonColor = Color(0xFF0F6973);
}
