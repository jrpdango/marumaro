import 'package:miru/models/enums.dart';

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

  factory MangaDetails.fromJson(Map<String, dynamic> json) {
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
    );
  }

  /// Rows displayed on the details page, in order.
  List<MapEntry<String, String>> get displayRows => <MapEntry<String, String>>[
        MapEntry("Number of Chapters", "$numChapters"),
        MapEntry("Number of Volumes", "$numVolumes"),
        MapEntry("Status", publishingStatus?.label ?? "Unknown"),
        MapEntry("Start Date", startDate ?? "-"),
        MapEntry("End Date", endDate ?? "-"),
        MapEntry("Rank", rank?.toString() ?? "-"),
        MapEntry("Popularity", popularity?.toString() ?? "-"),
        MapEntry("Source", source ?? "-"),
      ];
}
