/// Which kind of media a [UserListStatus] belongs to.
///
/// Anime and manga share most list fields but use different API key names for
/// progress, rewatch/reread, and value fields.
enum MediaKind { anime, manga }

/// The editable list status of an anime or manga for the current user.
///
/// This mirrors the `my_list_status` object returned by the MAL API and is the
/// single source of truth for building `PATCH .../my_list_status` bodies.
class UserListStatus {
  const UserListStatus({
    required this.status,
    required this.score,
    required this.progress,
    this.volumeProgress,
    this.startDate,
    this.finishDate,
    this.isRewatching = false,
    this.timesRewatched = 0,
    this.rewatchValue = 0,
    this.priority = 0,
    this.tags = "",
    this.comments = "",
  });

  /// The API value of the list status (e.g. `watching`).
  final String status;

  /// The user's score, 0-10.
  final int score;

  /// Episodes watched for anime, chapters read for manga.
  final int progress;

  /// Volumes read for manga; null for anime.
  final int? volumeProgress;

  final DateTime? startDate;
  final DateTime? finishDate;

  /// `is_rewatching` for anime, `is_rereading` for manga.
  final bool isRewatching;

  /// `num_times_rewatched` for anime, `num_times_reread` for manga.
  final int timesRewatched;

  /// `rewatch_value` for anime, `reread_value` for manga (0-5).
  final int rewatchValue;

  /// Priority, 0-2.
  final int priority;

  final String tags;
  final String comments;

  factory UserListStatus.fromJson(Map<String, dynamic> json, MediaKind kind) {
    final bool anime = kind == MediaKind.anime;
    return UserListStatus(
      status: (json["status"] as String?) ?? "",
      score: (json["score"] as int?) ?? 0,
      progress: anime
          ? (json["num_episodes_watched"] as int?) ?? 0
          : (json["num_chapters_read"] as int?) ?? 0,
      volumeProgress:
          anime ? null : (json["num_volumes_read"] as int?) ?? 0,
      startDate: parseDate(json["start_date"] as String?),
      finishDate: parseDate(json["finish_date"] as String?),
      isRewatching:
          (json[anime ? "is_rewatching" : "is_rereading"] as bool?) ?? false,
      timesRewatched: anime
          ? (json["num_times_rewatched"] as int?) ?? 0
          : (json["num_times_reread"] as int?) ?? 0,
      rewatchValue: anime
          ? (json["rewatch_value"] as int?) ?? 0
          : (json["reread_value"] as int?) ?? 0,
      priority: (json["priority"] as int?) ?? 0,
      tags: parseTags(json["tags"]),
      comments: (json["comments"] as String?) ?? "",
    );
  }

  /// Parses the `tags` field, which the API returns as a list of strings.
  ///
  /// Older/other responses may use a single string, so both are accepted.
  static String parseTags(dynamic value) {
    if (value is List) {
      return value.whereType<String>().join(", ");
    }
    if (value is String) return value;
    return "";
  }

  /// Parses a MAL date, tolerating partial values like `2017` or `2017-10`.
  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final List<String> parts = value.split("-");
    final int? year = int.tryParse(parts[0]);
    if (year == null) return null;
    final int month = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
    final int day = parts.length > 2 ? int.tryParse(parts[2]) ?? 1 : 1;
    return DateTime(year, month, day);
  }

  /// Formats a date as `YYYY-MM-DD`, or null when [date] is null.
  static String? serializeDate(DateTime? date) {
    if (date == null) return null;
    final String month = date.month.toString().padLeft(2, "0");
    final String day = date.day.toString().padLeft(2, "0");
    return "${date.year}-$month-$day";
  }

  /// Every patchable field, serialized with [kind]'s key names.
  ///
  /// Null dates are serialized as empty strings so they clear the value.
  Map<String, String> _fullBody(MediaKind kind) {
    final bool anime = kind == MediaKind.anime;
    final Map<String, String> body = <String, String>{
      "status": status,
      "score": "$score",
      "priority": "$priority",
      "start_date": serializeDate(startDate) ?? "",
      "finish_date": serializeDate(finishDate) ?? "",
      "tags": tags,
      "comments": comments,
    };
    if (anime) {
      body["num_watched_episodes"] = "$progress";
      body["is_rewatching"] = "$isRewatching";
      body["num_times_rewatched"] = "$timesRewatched";
      body["rewatch_value"] = "$rewatchValue";
    } else {
      body["num_chapters_read"] = "$progress";
      body["num_volumes_read"] = "${volumeProgress ?? 0}";
      body["is_rereading"] = "$isRewatching";
      body["num_times_reread"] = "$timesRewatched";
      body["reread_value"] = "$rewatchValue";
    }
    return body;
  }

  /// The subset of fields that differ from [original], ready for a PATCH body.
  Map<String, String> changedPatch(MediaKind kind, UserListStatus original) {
    final Map<String, String> next = _fullBody(kind);
    final Map<String, String> previous = original._fullBody(kind);
    return <String, String>{
      for (final MapEntry<String, String> entry in next.entries)
        if (previous[entry.key] != entry.value) entry.key: entry.value,
    };
  }
}
