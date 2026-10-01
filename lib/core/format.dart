/// Formats a count compactly for tight UI, e.g. `1234` -> `"1.2K"` and
/// `2227190` -> `"2.2M"`.
String formatCount(int value) {
  if (value < 1000) return "$value";
  // Promote to the next unit once one-decimal rounding would print e.g.
  // "1000K" instead of "1M".
  if (value < 999950) return "${_trimZero(value / 1000)}K";
  if (value < 999950000) return "${_trimZero(value / 1000000)}M";
  return "${_trimZero(value / 1000000000)}B";
}

String _trimZero(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith(".0") ? text.substring(0, text.length - 2) : text;
}
