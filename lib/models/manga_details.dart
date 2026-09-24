import 'package:miru/models/enums.dart';
import 'package:miru/models/media_details_data.dart';
import 'package:miru/models/user_list_status.dart';

/// Detailed information about a manga.
class MangaDetails {
  const MangaDetails({
    required this.meanScore,
    required this.numChapters,
    required this.numVolumes,
    required this.publishingStatus,
    required this.startDate,
    required this.endDate,
    required this.rank,
    required this.popularity,
    required this.source,
    this.myListStatus,
    this.synopsis,
    this.background,
    this.largePicture,
    this.englishTitle,
    this.japaneseTitle,
    this.synonyms = const <String>[],
    this.genres = const <String>[],
    this.authors = const <String>[],
    this.mediaType,
  });

  final double meanScore;
  final int numChapters;
  final int numVolumes;
  final MangaPublishingStatus? publishingStatus;
  final String? startDate;
  final String? endDate;
  final int? rank;
  final int? popularity;
  final String? source;

  final String? synopsis;
  final String? background;
  final Uri? largePicture;
  final String? englishTitle;
  final String? japaneseTitle;
  final List<String> synonyms;
  final List<String> genres;
  final List<String> authors;
  final String? mediaType;

  /// The current user's editable list status, when the manga is on their list.
  final UserListStatus? myListStatus;

  factory MangaDetails.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? myListStatus =
        (json["my_list_status"] as Map?)?.cast<String, dynamic>();
    final Map<String, dynamic>? mainPicture =
        (json["main_picture"] as Map?)?.cast<String, dynamic>();
    final Map<String, dynamic>? alternativeTitles =
        (json["alternative_titles"] as Map?)?.cast<String, dynamic>();
    return MangaDetails(
      meanScore: ((json["mean"] as num?) ?? 0).toDouble(),
      numChapters: (json["num_chapters"] as int?) ?? 0,
      numVolumes: (json["num_volumes"] as int?) ?? 0,
      publishingStatus:
          MangaPublishingStatus.fromApiValue(json["status"] as String?),
      startDate: json["start_date"] as String?,
      endDate: json["end_date"] as String?,
      rank: json["rank"] as int?,
      popularity: json["popularity"] as int?,
      source: json["source"] as String?,
      synopsis: _clean(json["synopsis"] as String?),
      background: _clean(json["background"] as String?),
      largePicture: _parseUri(mainPicture?["large"] as String?),
      englishTitle: _emptyToNull(alternativeTitles?["en"] as String?),
      japaneseTitle: _emptyToNull(alternativeTitles?["ja"] as String?),
      synonyms: _strings(alternativeTitles?["synonyms"]),
      genres: _names(json["genres"]),
      authors: _authors(json["authors"]),
      mediaType: _emptyToNull(json["media_type"] as String?),
      myListStatus: myListStatus == null
          ? null
          : UserListStatus.fromJson(myListStatus, MediaKind.manga),
    );
  }

  /// Rows displayed in the details information grid, in order.
  List<MapEntry<String, String>> get displayRows => <MapEntry<String, String>>[
        MapEntry("Chapters", "$numChapters"),
        MapEntry("Volumes", "$numVolumes"),
        MapEntry("Status", publishingStatus?.label ?? "Unknown"),
        MapEntry("Published", _dateRange(startDate, endDate)),
        MapEntry("Rank", rank?.toString() ?? "-"),
        MapEntry("Popularity", popularity?.toString() ?? "-"),
        MapEntry("Source", source ?? "-"),
        if (authors.isNotEmpty) MapEntry("Authors", authors.join(", ")),
      ];

  /// Maps this detail model into the shared details view shape.
  MediaDetailsData toViewData({
    required int id,
    required String title,
    required Uri poster,
  }) {
    return MediaDetailsData(
      kind: MediaKind.manga,
      id: id,
      title: title,
      poster: poster,
      backdrop: largePicture ?? poster,
      meanScore: meanScore,
      statusLabel: publishingStatus?.label ?? "Unknown",
      infoRows: displayRows,
      rank: rank,
      popularity: popularity,
      synopsis: synopsis,
      background: background,
      genres: genres,
      studios: authors,
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

List<String> _authors(dynamic value) {
  if (value is! List) return const <String>[];
  final List<String> names = <String>[];
  for (final dynamic entry in value) {
    final Map? node = (entry as Map)["node"] as Map?;
    if (node == null) continue;
    final String name = <String?>[
      node["first_name"] as String?,
      node["last_name"] as String?,
    ].whereType<String>().join(" ").trim();
    if (name.isNotEmpty) names.add(name);
  }
  return names;
}

String _dateRange(String? start, String? end) {
  if (start == null && end == null) return "-";
  if (start != null && end != null) return "$start to $end";
  return start ?? "? to $end";
}
