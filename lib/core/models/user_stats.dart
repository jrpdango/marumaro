import 'package:marumaro/core/models/anime.dart';
import 'package:marumaro/core/models/enums.dart';
import 'package:marumaro/core/models/manga.dart';
import 'package:marumaro/core/models/user_statistics.dart';

/// The number of list entries in a single status bucket.
class StatusCount {
  const StatusCount({
    required this.status,
    required this.label,
    required this.count,
  });

  /// The MAL API status value (e.g. `watching`).
  final String status;

  /// A compact human-readable label.
  final String label;

  final int count;
}

/// Statistics for one media kind, computed from the cached list.
///
/// Covers dimensions the server aggregates do not expose (score histogram,
/// status breakdown), so it powers the profile charts.
class MediaStats {
  const MediaStats({
    required this.total,
    required this.statuses,
    required this.scoredCount,
    required this.meanScore,
    required this.medianScore,
    required this.scoreHistogram,
    required this.totalProgress,
    required this.totalVolumes,
  });

  /// Total number of entries.
  final int total;

  /// Per-status counts, in enum order, excluding empty buckets.
  final List<StatusCount> statuses;

  /// How many entries have a score greater than zero.
  final int scoredCount;

  /// Mean of the scored entries, or zero when none are scored.
  final double meanScore;

  /// Median of the scored entries, or zero when none are scored.
  final double medianScore;

  /// Counts indexed by score: index `0` is score `1`, index `9` is score `10`.
  final List<int> scoreHistogram;

  /// Episodes watched (anime) or chapters read (manga).
  final int totalProgress;

  /// Volumes read; always zero for anime.
  final int totalVolumes;

  static const MediaStats empty = MediaStats(
    total: 0,
    statuses: <StatusCount>[],
    scoredCount: 0,
    meanScore: 0,
    medianScore: 0,
    scoreHistogram: <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    totalProgress: 0,
    totalVolumes: 0,
  );

  bool get hasScores => scoredCount > 0;

  /// Number of entries in [status], or zero when absent.
  int countFor(String status) {
    int total = 0;
    for (final StatusCount entry in statuses) {
      if (entry.status == status) total += entry.count;
    }
    return total;
  }

  int get completedCount => countFor("completed");

  /// Completed entries as a fraction of the total, in the range 0..1.
  double get completionRate => total == 0 ? 0 : completedCount / total;

  factory MediaStats.fromAnime(Iterable<Anime> items) {
    final List<Anime> list = items.toList(growable: false);
    final List<StatusCount> statuses = <StatusCount>[
      for (final AnimeListStatus status in AnimeListStatus.values)
        if (list.any((Anime a) => a.userStatus == status))
          StatusCount(
            status: status.apiValue,
            label: status.shortLabel,
            count: list.where((Anime a) => a.userStatus == status).length,
          ),
    ];
    return _build(
      list.length,
      statuses,
      list.map((Anime a) => a.userScore),
      list.fold(0, (int sum, Anime a) => sum + a.userEpisodesWatched),
      volumes: 0,
    );
  }

  factory MediaStats.fromManga(Iterable<Manga> items) {
    final List<Manga> list = items.toList(growable: false);
    final List<StatusCount> statuses = <StatusCount>[
      for (final MangaListStatus status in MangaListStatus.values)
        if (list.any((Manga m) => m.userStatus == status))
          StatusCount(
            status: status.apiValue,
            label: status.shortLabel,
            count: list.where((Manga m) => m.userStatus == status).length,
          ),
    ];
    return _build(
      list.length,
      statuses,
      list.map((Manga m) => m.userScore),
      list.fold(0, (int sum, Manga m) => sum + m.userChaptersRead),
      volumes: list.fold(0, (int sum, Manga m) => sum + m.userVolumesRead),
    );
  }

  static MediaStats _build(
    int total,
    List<StatusCount> statuses,
    Iterable<int> scoreValues,
    int totalProgress, {
    required int volumes,
  }) {
    final List<int> scores =
        scoreValues.where((int score) => score > 0).toList(growable: false);
    final List<int> histogram = List<int>.filled(10, 0);
    for (final int score in scores) {
      if (score >= 1 && score <= 10) histogram[score - 1]++;
    }
    return MediaStats(
      total: total,
      statuses: statuses,
      scoredCount: scores.length,
      meanScore: _mean(scores),
      medianScore: _median(scores),
      scoreHistogram: histogram,
      totalProgress: totalProgress,
      totalVolumes: volumes,
    );
  }

  static double _mean(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((int a, int b) => a + b) / values.length;
  }

  static double _median(List<int> values) {
    if (values.isEmpty) return 0;
    final List<int> sorted = List<int>.of(values)..sort();
    final int middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[middle].toDouble();
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }
}

/// Combined anime and manga statistics for the profile page.
///
/// Holds both the locally computed [MediaStats] and, when available, the
/// server-provided [MediaStatistics] lifetime aggregates. The convenience
/// getters prefer the server values for headline numbers.
class ProfileStats {
  const ProfileStats({
    required this.anime,
    required this.manga,
    this.animeServer,
    this.mangaServer,
  });

  final MediaStats anime;
  final MediaStats manga;
  final MediaStatistics? animeServer;
  final MediaStatistics? mangaServer;

  factory ProfileStats.fromLists(
    Iterable<Anime> anime,
    Iterable<Manga> manga, {
    MediaStatistics? animeServer,
    MediaStatistics? mangaServer,
  }) {
    return ProfileStats(
      anime: MediaStats.fromAnime(anime),
      manga: MediaStats.fromManga(manga),
      animeServer: animeServer,
      mangaServer: mangaServer,
    );
  }

  bool get isEmpty => anime.total == 0 && manga.total == 0;

  int get animeTotal => animeServer?.items ?? anime.total;
  int get mangaTotal => mangaServer?.items ?? manga.total;
  int get totalEpisodes => animeServer?.episodes ?? anime.totalProgress;
  int get totalChapters => mangaServer?.chapters ?? manga.totalProgress;
  int get totalVolumes => mangaServer?.volumes ?? manga.totalVolumes;

  double? get animeMeanScore =>
      animeServer?.meanScore ?? (anime.hasScores ? anime.meanScore : null);
  double? get mangaMeanScore =>
      mangaServer?.meanScore ?? (manga.hasScores ? manga.meanScore : null);

  int? get animeRewatches => animeServer?.timesRewatched;
  int? get mangaRereads => mangaServer?.timesRewatched;
}
