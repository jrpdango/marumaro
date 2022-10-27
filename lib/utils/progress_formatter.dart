class ProgressFormatter {
  static String? format(int? progress) {
    if (progress == null) return null;
    if (progress == 0) {
      return '?';
    } else {
      return '$progress';
    }
  }
}
