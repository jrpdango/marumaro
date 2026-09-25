import 'package:marumaro/core/models/enums.dart';
import 'package:marumaro/core/models/media_details_data.dart';
import 'package:marumaro/core/models/user_list_status.dart';

/// Detailed information about an anime.
class AnimeDetails {
  const AnimeDetails({
    required this.meanScore,
    required this.numEpisodes,
    required this.airingStatus,
    required this.startDate,
    required this.endDate,
    required this.rank,
    required this.popularity,
    required this.source,
    required this.rating,
    required this.averageEpisodeDuration,
    this.myListStatus,
    this.synopsis,
    this.background,
    this.largePicture,
    this.englishTitle,
    this.japaneseTitle,
    this.synonyms = const <String>[],
    this.genres = const <String>[],
    this.studios = const <String>[],
    this.broadcast,
    this.mediaType,
  });

  final double meanScore;
  final int numEpisodes;
  final AnimeAiringStatus? airingStatus;
  final String? startDate;
  final String? endDate;
  final int? rank;
  final int? popularity;
  final String? source;
  final String? rating;
  final int? averageEpisodeDuration;

  final String? synopsis;
  final String? background;
  final Uri? largePicture;
  final String? englishTitle;
  final String? japaneseTitle;
  final List<String> synonyms;
  final List<String> genres;
  final List<String> studios;
  final String? broadcast;
  final String? mediaType;

  /// The current user's editable list status, when the anime is on their list.
  final UserListStatus? myListStatus;

  factory AnimeDetails.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? myListStatus =
        (json["my_list_status"] as Map?)?.cast<String, dynamic>();
    final Map<String, dynamic>? mainPicture =
        (json["main_picture"] as Map?)?.cast<String, dynamic>();
    final Map<String, dynamic>? alternativeTitles =
        (json["alternative_titles"] as Map?)?.cast<String, dynamic>();
    return AnimeDetails(
      meanScore: ((json["mean"] as num?) ?? 0).toDouble(),
      numEpisodes: (json["num_episodes"] as int?) ?? 0,
      airingStatus: AnimeAiringStatus.fromApiValue(json["status"] as String?),
      startDate: json["start_date"] as String?,
      endDate: json["end_date"] as String?,
      rank: json["rank"] as int?,
      popularity: json["popularity"] as int?,
      source: json["source"] as String?,
      rating: json["rating"] as String?,
      averageEpisodeDuration: json["average_episode_duration"] as int?,
      synopsis: _clean(json["synopsis"] as String?),
      background: _clean(json["background"] as String?),
      largePicture: _parseUri(mainPicture?["large"] as String?),
      englishTitle: _emptyToNull(alternativeTitles?["en"] as String?),
      japaneseTitle: _emptyToNull(alternativeTitles?["ja"] as String?),
      synonyms: _strings(alternativeTitles?["synonyms"]),
      genres: _names(json["genres"]),
      studios: _names(json["studios"]),
      broadcast: _broadcast(json["broadcast"]),
      mediaType: _emptyToNull(json["media_type"] as String?),
      myListStatus: myListStatus == null
          ? null
          : UserListStatus.fromJson(myListStatus, MediaKind.anime),
    );
  }

  /// Rows displayed in the details information grid, in order.
  List<MapEntry<String, String>> get displayRows => <MapEntry<String, String>>[
        MapEntry("Episodes", "$numEpisodes"),
        MapEntry("Status", airingStatus?.label ?? "Unknown"),
        MapEntry("Aired", _dateRange(startDate, endDate)),
        MapEntry("Rank", rank?.toString() ?? "-"),
        MapEntry("Popularity", popularity?.toString() ?? "-"),
        MapEntry("Source", source ?? "-"),
        MapEntry("Rating", rating ?? "-"),
        MapEntry(
          "Duration",
          averageEpisodeDuration == null
              ? "-"
              : "${averageEpisodeDuration! ~/ 60} min",
        ),
        if (broadcast != null) MapEntry("Broadcast", broadcast!),
        if (studios.isNotEmpty) MapEntry("Studios", studios.join(", ")),
      ];

  /// Maps this detail model into the shared details view shape.
  MediaDetailsData toViewData({
    required int id,
    required String title,
    required Uri poster,
  }) {
    return MediaDetailsData(
      kind: MediaKind.anime,
      id: id,
      title: title,
      poster: poster,
      backdrop: largePicture ?? poster,
      meanScore: meanScore,
      statusLabel: airingStatus?.label ?? "Unknown",
      infoRows: displayRows,
      rank: rank,
      popularity: popularity,
      synopsis: synopsis,
      background: background,
      genres: genres,
      studios: studios,
      mediaType: mediaType,
      englishTitle: englishTitle,
      japaneseTitle: japaneseTitle,
      synonyms: synonyms,
    );
  }
}

String? _emptyToNull(String? value) =>
    (value == null || value.trim().isEmpty) ? null : value.trim();

String? _clean(String? value) {
  final String? trimmed = _emptyToNull(value);
  if (trimmed == null) return null;
  return trimmed
      .replaceAll(RegExp(r"\[Written by[^\]]*\]", caseSensitive: false), "")
      .trim();
}

Uri? _parseUri(String? value) =>
    (value == null || value.isEmpty) ? null : Uri.tryParse(value);

List<String> _names(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((dynamic entry) => (entry as Map)["name"] as String? ?? "")
      .where((String name) => name.isNotEmpty)
      .toList(growable: false);
}

List<String> _strings(dynamic value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

String _dateRange(String? start, String? end) {
  if (start == null && end == null) return "-";
  if (start != null && end != null) return "$start to $end";
  return start ?? "? to $end";
}

String? _broadcast(dynamic value) {
  if (value is! Map) return null;
  final String? day = value["day_of_the_week"] as String?;
  final String? time = value["start_time"] as String?;
  if (day == null) return null;
  final String label = day[0].toUpperCase() + day.substring(1);
  return time == null ? label : "$label at $time";
}
