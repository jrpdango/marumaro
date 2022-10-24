import 'package:flutter/material.dart' show Color;

/// Limit of how many list items can be retrieved in one call.
const int limitOfListItems = 300;

/// MAL API URL for generating or refreshing token pairs.
const String apiTokenUrl = 'https://myanimelist.net/v1/oauth2/token';

/// Contains custom colors for the app.
class MiruColors {
  static const Color primaryColor = Color.fromARGB(255, 33, 233, 255);
  static const Color primaryVariant = Color.fromARGB(255, 30, 205, 224);
  static const Color textColor = Color.fromARGB(255, 253, 255, 255);
  static const Color unselectedItemColor = Color.fromARGB(255, 187, 189, 189);
  static const Color tabBarBackgroundColor = Color.fromARGB(255, 28, 28, 28);
  static const Color backgroundColor = Color.fromARGB(255, 33, 33, 33);
  static const Color cardColor = Color.fromARGB(255, 46, 46, 46);
  static const Color buttonColor = Color.fromARGB(255, 10, 150, 165);
  static const Color unselectedButtonColor = Color.fromARGB(255, 76, 112, 116);
}
