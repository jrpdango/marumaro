import 'package:flutter_test/flutter_test.dart';
import 'package:tamarun/core/core.dart';

void main() {
  group("MediaSeason.current", () {
    test("maps each month to its season", () {
      expect(MediaSeason.current(DateTime(2026, 1)), MediaSeason.winter);
      expect(MediaSeason.current(DateTime(2026, 3)), MediaSeason.winter);
      expect(MediaSeason.current(DateTime(2026, 4)), MediaSeason.spring);
      expect(MediaSeason.current(DateTime(2026, 6)), MediaSeason.spring);
      expect(MediaSeason.current(DateTime(2026, 7)), MediaSeason.summer);
      expect(MediaSeason.current(DateTime(2026, 9)), MediaSeason.summer);
      expect(MediaSeason.current(DateTime(2026, 10)), MediaSeason.fall);
      expect(MediaSeason.current(DateTime(2026, 12)), MediaSeason.fall);
    });
  });

  group("SeasonRef", () {
    test("derives the current season and year", () {
      final SeasonRef ref = SeasonRef.current(DateTime(2026, 10, 5));
      expect(ref.year, 2026);
      expect(ref.season, MediaSeason.fall);
      expect(ref.label, "Fall 2026");
    });

    test("compares by value", () {
      const SeasonRef a =
          SeasonRef(year: 2023, season: MediaSeason.summer);
      const SeasonRef b =
          SeasonRef(year: 2023, season: MediaSeason.summer);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group("Anime.fromNodeJson", () {
    test("parses a seasonal/ranking entry with no list status", () {
      final Anime anime = Anime.fromNodeJson(<String, dynamic>{
        "node": <String, dynamic>{
          "id": 42,
          "title": "Test Anime",
          "main_picture": <String, dynamic>{
            "medium": "https://example.com/m.jpg",
          },
          "num_episodes": 12,
          "status": "currently_airing",
          "mean": 8.5,
          "media_type": "tv",
        },
        "ranking": <String, dynamic>{"rank": 3},
      });

      expect(anime.id, 42);
      expect(anime.title, "Test Anime");
      expect(anime.picture, Uri.parse("https://example.com/m.jpg"));
      expect(anime.totalEpisodes, 12);
      expect(anime.showStatus, AnimeAiringStatus.currentlyAiring);
      expect(anime.inList, isFalse);
      expect(anime.meanScore, 8.5);
      expect(anime.rank, 3);
      expect(anime.mediaType, "tv");
    });

    test("tolerates a bare node without a ranking wrapper", () {
      final Anime anime = Anime.fromNodeJson(<String, dynamic>{
        "id": 7,
        "title": "Bare",
        "num_episodes": 0,
      });

      expect(anime.id, 7);
      expect(anime.inList, isFalse);
      expect(anime.rank, isNull);
      expect(anime.meanScore, isNull);
    });
  });

  group("Manga.fromNodeJson", () {
    test("parses a ranking entry with no list status", () {
      final Manga manga = Manga.fromNodeJson(<String, dynamic>{
        "node": <String, dynamic>{
          "id": 99,
          "title": "Test Manga",
          "main_picture": <String, dynamic>{
            "medium": "https://example.com/mm.jpg",
          },
          "num_chapters": 30,
          "num_volumes": 5,
          "status": "currently_publishing",
          "mean": 9.0,
          "media_type": "manga",
        },
        "ranking": <String, dynamic>{"rank": 1},
      });

      expect(manga.id, 99);
      expect(manga.totalChapters, 30);
      expect(manga.totalVolumes, 5);
      expect(manga.publishingStatus, MangaPublishingStatus.currentlyPublishing);
      expect(manga.inList, isFalse);
      expect(manga.meanScore, 9.0);
      expect(manga.rank, 1);
      expect(manga.mediaType, "manga");
    });
  });

  test("copyWith preserves browse-only fields", () {
    final Anime anime = Anime.fromNodeJson(<String, dynamic>{
      "node": <String, dynamic>{
        "id": 1,
        "title": "A",
        "num_episodes": 1,
        "mean": 7.5,
        "media_type": "tv",
      },
      "ranking": <String, dynamic>{"rank": 9},
    });

    final Anime updated = anime.copyWith(
      userStatus: AnimeListStatus.watching,
      userEpisodesWatched: 1,
    );

    expect(updated.inList, isFalse);
    expect(updated.meanScore, 7.5);
    expect(updated.rank, 9);
    expect(updated.mediaType, "tv");
    expect(updated.userStatus, AnimeListStatus.watching);
  });
}
