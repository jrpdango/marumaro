import 'package:miru/core/models/enums.dart';

/// An anime entry from the user's list.
class Anime {
  const Anime({
    required this.id,
    required this.title,
    required this.picture,
    required this.totalEpisodes,
    required this.showStatus,
    required this.userStatus,
    required this.userEpisodesWatched,
    required this.userScore,
    required this.updatedAt,
    this.inList = true,
    this.meanScore,
    this.rank,
    this.mediaType,
  });

  final int id;
  final String title;
  final Uri picture;
  final int totalEpisodes;
  final AnimeAiringStatus? showStatus;
  final AnimeListStatus userStatus;
  final int userEpisodesWatched;
  final int userScore;
  final DateTime updatedAt;

  /// Whether this anime is on the user's list. False for browse results.
  final bool inList;

  /// The community mean score, when supplied by browse endpoints.
  final double? meanScore;

  /// The ranking position, when supplied by ranking/seasonal endpoints.
  final int? rank;

  /// The media type (e.g. `tv`, `movie`), when supplied by browse endpoints.
  final String? mediaType;

  factory Anime.fromListStatusJson(Map<String, dynamic> json) {
    final Map<String, dynamic> node =
        (json["node"] as Map).cast<String, dynamic>();
    final Map<String, dynamic> listStatus =
        (json["list_status"] as Map).cast<String, dynamic>();
    final String? picture = (node["main_picture"] as Map?)?["medium"] as String?;
    return Anime(
      id: node["id"] as int,
      title: (node["title"] as String?) ?? "",
      picture: Uri.parse(picture ?? ""),
      totalEpisodes: (node["num_episodes"] as int?) ?? 0,
      showStatus: AnimeAiringStatus.fromApiValue(node["status"] as String?),
      userStatus:
          AnimeListStatus.fromApiValue(listStatus["status"] as String?),
      userEpisodesWatched:
          (listStatus["num_episodes_watched"] as int?) ?? 0,
      userScore: (listStatus["score"] as int?) ?? 0,
      updatedAt: DateTime.tryParse(
            (listStatus["updated_at"] as String?) ?? "",
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Parses an anime returned by the browse endpoints (seasonal, ranking, or
  /// suggestions), which have no `list_status` and therefore are not on the
  /// user's list.
  factory Anime.fromNodeJson(Map<String, dynamic> json) {
    final Map<String, dynamic> node =
        (json["node"] as Map?)?.cast<String, dynamic>() ?? json;
    final Map<String, dynamic>? ranking =
        (json["ranking"] as Map?)?.cast<String, dynamic>();
    final String? picture = (node["main_picture"] as Map?)?["medium"] as String?;
    return Anime(
      id: node["id"] as int,
      title: (node["title"] as String?) ?? "",
      picture: Uri.parse(picture ?? ""),
      totalEpisodes: (node["num_episodes"] as int?) ?? 0,
      showStatus: AnimeAiringStatus.fromApiValue(node["status"] as String?),
      userStatus: AnimeListStatus.planToWatch,
      userEpisodesWatched: 0,
      userScore: 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      inList: false,
      meanScore: (node["mean"] as num?)?.toDouble(),
      rank: ranking?["rank"] as int?,
      mediaType: node["media_type"] as String?,
    );
  }

  Anime copyWith({
    AnimeListStatus? userStatus,
    int? userEpisodesWatched,
    int? userScore,
    DateTime? updatedAt,
    bool? inList,
    double? meanScore,
    int? rank,
    String? mediaType,
  }) {
    return Anime(
      id: id,
      title: title,
      picture: picture,
      totalEpisodes: totalEpisodes,
      showStatus: showStatus,
      userStatus: userStatus ?? this.userStatus,
      userEpisodesWatched: userEpisodesWatched ?? this.userEpisodesWatched,
      userScore: userScore ?? this.userScore,
      updatedAt: updatedAt ?? this.updatedAt,
      inList: inList ?? this.inList,
      meanScore: meanScore ?? this.meanScore,
      rank: rank ?? this.rank,
      mediaType: mediaType ?? this.mediaType,
    );
  }
}
