import 'package:miru/models/enums.dart';
import 'package:miru/models/user_list_status.dart';

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

  /// The current user's editable list status, when the anime is on their list.
  final UserListStatus? myListStatus;

  factory AnimeDetails.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? myListStatus =
        (json["my_list_status"] as Map?)?.cast<String, dynamic>();
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
      myListStatus: myListStatus == null
          ? null
          : UserListStatus.fromJson(myListStatus, MediaKind.anime),
    );
  }

  /// Rows displayed on the details page, in order.
  List<MapEntry<String, String>> get displayRows => <MapEntry<String, String>>[
        MapEntry("Number of Episodes", "$numEpisodes"),
        MapEntry("Status", airingStatus?.label ?? "Unknown"),
        MapEntry("Start Date", startDate ?? "-"),
        MapEntry("End Date", endDate ?? "-"),
        MapEntry("Rank", rank?.toString() ?? "-"),
        MapEntry("Popularity", popularity?.toString() ?? "-"),
        MapEntry("Source", source ?? "-"),
        MapEntry("Rating", rating ?? "-"),
        MapEntry(
          "Average Episode Duration",
          averageEpisodeDuration == null
              ? "-"
              : "${averageEpisodeDuration! ~/ 60} min",
        ),
      ];
}
