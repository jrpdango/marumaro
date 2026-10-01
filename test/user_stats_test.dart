import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';

Anime _anime(
  int id, {
  required AnimeListStatus status,
  int score = 0,
  int episodes = 0,
}) {
  return Anime(
    id: id,
    title: "Anime $id",
    picture: Uri.parse("https://example.com/$id.jpg"),
    totalEpisodes: 12,
    showStatus: AnimeAiringStatus.finishedAiring,
    userStatus: status,
    userEpisodesWatched: episodes,
    userScore: score,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

Manga _manga(
  int id, {
  required MangaListStatus status,
  int score = 0,
  int chapters = 0,
  int volumes = 0,
}) {
  return Manga(
    id: id,
    title: "Manga $id",
    picture: Uri.parse("https://example.com/m$id.jpg"),
    totalChapters: 30,
    totalVolumes: 4,
    publishingStatus: MangaPublishingStatus.finished,
    userStatus: status,
    userChaptersRead: chapters,
    userVolumesRead: volumes,
    userScore: score,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

void main() {
  group("MediaStats.fromAnime", () {
    test("aggregates totals, statuses, scores and progress", () {
      final MediaStats stats = MediaStats.fromAnime(<Anime>[
        _anime(
          1,
          status: AnimeListStatus.completed,
          score: 10,
          episodes: 12,
        ),
        _anime(2, status: AnimeListStatus.completed, score: 8, episodes: 12),
        _anime(3, status: AnimeListStatus.watching, score: 8, episodes: 3),
        _anime(4, status: AnimeListStatus.planToWatch),
      ]);

      expect(stats.total, 4);
      expect(stats.totalProgress, 27);
      expect(stats.totalVolumes, 0);
      expect(stats.completedCount, 2);
      expect(stats.completionRate, 0.5);
      expect(stats.countFor("watching"), 1);
      expect(stats.scoredCount, 3);
      expect(stats.meanScore, closeTo(8.67, 0.01));
      expect(stats.medianScore, 8);
      expect(stats.scoreHistogram[7], 2);
      expect(stats.scoreHistogram[9], 1);
      expect(stats.statuses.map((StatusCount s) => s.status), <String>[
        "watching",
        "plan_to_watch",
        "completed",
      ]);
    });

    test("an empty list yields empty stats", () {
      final MediaStats stats = MediaStats.fromAnime(const <Anime>[]);

      expect(stats.total, 0);
      expect(stats.hasScores, isFalse);
      expect(stats.meanScore, 0);
      expect(stats.medianScore, 0);
      expect(stats.completionRate, 0);
      expect(stats.scoreHistogram.every((int c) => c == 0), isTrue);
    });
  });

  test("MediaStats.fromManga aggregates chapters and volumes", () {
    final MediaStats stats = MediaStats.fromManga(<Manga>[
      _manga(
        1,
        status: MangaListStatus.completed,
        score: 9,
        chapters: 30,
        volumes: 4,
      ),
      _manga(
        2,
        status: MangaListStatus.reading,
        chapters: 10,
        volumes: 2,
      ),
    ]);

    expect(stats.total, 2);
    expect(stats.totalProgress, 40);
    expect(stats.totalVolumes, 6);
    expect(stats.scoredCount, 1);
    expect(stats.medianScore, 9);
  });

  test("median averages the middle pair for an even count", () {
    final MediaStats stats = MediaStats.fromAnime(<Anime>[
      _anime(1, status: AnimeListStatus.completed, score: 4),
      _anime(2, status: AnimeListStatus.completed, score: 6),
      _anime(3, status: AnimeListStatus.completed, score: 8),
      _anime(4, status: AnimeListStatus.completed, score: 10),
    ]);

    expect(stats.medianScore, 7);
  });

  test("ProfileStats prefers server aggregates for headline numbers", () {
    final ProfileStats stats = ProfileStats.fromLists(
      <Anime>[_anime(1, status: AnimeListStatus.completed, score: 8)],
      <Manga>[],
      animeServer: const MediaStatistics(
        items: 999,
        episodes: 5000,
        meanScore: 9.5,
        timesRewatched: 12,
      ),
    );

    expect(stats.animeTotal, 999);
    expect(stats.totalEpisodes, 5000);
    expect(stats.animeMeanScore, 9.5);
    expect(stats.animeRewatches, 12);
    expect(stats.mangaTotal, 0);
  });

  test("ProfileStats falls back to computed values without server stats", () {
    final ProfileStats stats = ProfileStats.fromLists(
      <Anime>[_anime(1, status: AnimeListStatus.completed, score: 8)],
      <Manga>[],
    );

    expect(stats.animeTotal, 1);
    expect(stats.animeMeanScore, 8);
    expect(stats.isEmpty, isFalse);
  });

  test("ProfileStats reports empty when both lists are empty", () {
    expect(ProfileStats.fromLists(<Anime>[], <Manga>[]).isEmpty, isTrue);
  });
}
