/// Parses the `nsfw` field MAL returns on anime and manga nodes.
///
/// The API uses string values (`white` for safe, `gray` for mild, and `black`
/// for explicit content), though older responses and tests may carry a bool.
/// `gray` and `black` are treated as adult content.
bool parseIsNsfw(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    final String normalized = value.toLowerCase();
    return normalized == "gray" || normalized == "black";
  }
  return false;
}
