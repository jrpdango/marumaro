class TextCleaner {
  /// Turns given [text] into valid text to send back through the MAL API.
  ///
  /// ```dart
  /// jsonify("Plan To Watch"); // plan_to_watch
  /// ```
  static String jsonify(String text) {
    if (text.isEmpty) return "";
    return text.replaceAll(" ", "_").toLowerCase();
  }

  /// Turns given [text] into prettier text to display on the app.
  ///
  /// ```dart
  /// unjsonify("plan_to_watch"); // Plan To Watch
  /// ```
  static String unjsonify(String text) {
    if (text.isEmpty) return "";
    if (!text.contains("_") && text != "pg") {
      return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
    }
    if (int.tryParse(text) != null) return text;
    switch (text) {
      case "num_episodes":
        return "Number of Episodes";
      case "pg":
        return "PG - Children";
      case "pg_13":
        return "PG-13 - Teens 13 or older";
      case "r":
        return "R";
      case "4_koma_manga":
        return "4-koma Manga";
      default:
        String newText = "${text[0].toUpperCase()}";
        for (int i = 1; i < text.length; i++) {
          if (text[i] == "_") {
            newText = "$newText ${text[i + 1].toUpperCase()}";
            i++;
            continue;
          }
          newText = "$newText${text[i]}";
        }
        return newText;
    }
  }
}
