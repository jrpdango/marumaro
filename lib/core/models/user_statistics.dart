/// Lifetime list statistics for one media kind, as returned by the MAL
/// `anime_statistics` / `manga_statistics` fields of the user endpoint.
///
/// These are server-side aggregates over the user's entire list, so they are
/// authoritative even for entries not yet cached locally.
class MediaStatistics {
  const MediaStatistics({
    required this.items,
    this.episodes,
    this.chapters,
    this.volumes,
    this.timesRewatched,
    this.meanScore,
  });

  /// Total number of entries on the list.
  final int items;

  /// Episodes watched; anime only.
  final int? episodes;

  /// Chapters read; manga only.
  final int? chapters;

  /// Volumes read; manga only.
  final int? volumes;

  /// `num_times_rewatched` (anime) or `num_times_reread` (manga).
  final int? timesRewatched;

  /// The mean of the user's scores across the list.
  final double? meanScore;

  factory MediaStatistics.fromAnimeJson(Map<String, dynamic> json) {
    return MediaStatistics(
      items: _int(json["num_items"]) ?? 0,
      episodes: _int(json["num_episodes"]),
      timesRewatched: _int(json["num_times_rewatched"]),
      meanScore: _double(json["mean_score"]),
    );
  }

  factory MediaStatistics.fromMangaJson(Map<String, dynamic> json) {
    return MediaStatistics(
      items: _int(json["num_items"]) ?? 0,
      chapters: _int(json["num_chapters"]),
      volumes: _int(json["num_volumes"]),
      timesRewatched: _int(json["num_times_reread"]),
      meanScore: _double(json["mean_score"]),
    );
  }

  static int? _int(dynamic value) => (value as num?)?.toInt();

  static double? _double(dynamic value) => (value as num?)?.toDouble();
}
