/// The user's status for an anime in their list.
enum AnimeListStatus {
  watching("watching", "Currently Watching"),
  planToWatch("plan_to_watch", "Plan To Watch"),
  completed("completed", "Completed"),
  onHold("on_hold", "On Hold"),
  dropped("dropped", "Dropped");

  const AnimeListStatus(this.apiValue, this.label);

  /// The value used by the MAL API.
  final String apiValue;

  /// A human-readable label.
  final String label;

  static AnimeListStatus fromApiValue(String? value) {
    return values.firstWhere(
      (AnimeListStatus status) => status.apiValue == value,
      orElse: () => AnimeListStatus.watching,
    );
  }
}

/// The user's status for a manga in their list.
enum MangaListStatus {
  reading("reading", "Currently Reading"),
  planToRead("plan_to_read", "Plan To Read"),
  completed("completed", "Completed"),
  onHold("on_hold", "On Hold"),
  dropped("dropped", "Dropped");

  const MangaListStatus(this.apiValue, this.label);

  /// The value used by the MAL API.
  final String apiValue;

  /// A human-readable label.
  final String label;

  static MangaListStatus fromApiValue(String? value) {
    return values.firstWhere(
      (MangaListStatus status) => status.apiValue == value,
      orElse: () => MangaListStatus.reading,
    );
  }
}

/// The publication status of a manga as reported by the MAL API.
enum MangaPublishingStatus {
  finished("finished", "Finished"),
  currentlyPublishing("currently_publishing", "Currently Publishing"),
  notYetPublished("not_yet_published", "Not Yet Published");

  const MangaPublishingStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static MangaPublishingStatus? fromApiValue(String? value) {
    for (final MangaPublishingStatus status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}

/// The user's selected color theme.
enum AppThemeMode {
  system("system", "System"),
  light("light", "Light"),
  dark("dark", "Dark"),
  amoled("amoled", "AMOLED Dark");

  const AppThemeMode(this.storageValue, this.label);

  /// The value persisted in the local store.
  final String storageValue;

  /// A human-readable label.
  final String label;

  static AppThemeMode fromStorageValue(String? value) {
    return values.firstWhere(
      (AppThemeMode mode) => mode.storageValue == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

/// The airing status of an anime as reported by the MAL API.
enum AnimeAiringStatus {
  finishedAiring("finished_airing", "Finished Airing"),
  currentlyAiring("currently_airing", "Currently Airing"),
  notYetAired("not_yet_aired", "Not Yet Aired");

  const AnimeAiringStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AnimeAiringStatus? fromApiValue(String? value) {
    for (final AnimeAiringStatus status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}

/// A season of the year used by the MAL seasonal anime endpoint.
enum MediaSeason {
  winter("winter", "Winter"),
  spring("spring", "Spring"),
  summer("summer", "Summer"),
  fall("fall", "Fall");

  const MediaSeason(this.apiValue, this.label);

  /// The value used by the MAL API.
  final String apiValue;

  /// A human-readable label.
  final String label;

  /// The season [date] falls in.
  static MediaSeason current(DateTime date) {
    final int month = date.month;
    if (month <= 3) return MediaSeason.winter;
    if (month <= 6) return MediaSeason.spring;
    if (month <= 9) return MediaSeason.summer;
    return MediaSeason.fall;
  }

  static MediaSeason fromApiValue(String? value) {
    return values.firstWhere(
      (MediaSeason season) => season.apiValue == value,
      orElse: () => MediaSeason.winter,
    );
  }
}

/// A year and season pair, e.g. Fall 2026.
class SeasonRef {
  const SeasonRef({required this.year, required this.season});

  final int year;
  final MediaSeason season;

  /// The season containing [now], or the current season by default.
  factory SeasonRef.current([DateTime? now]) {
    final DateTime date = now ?? DateTime.now();
    return SeasonRef(year: date.year, season: MediaSeason.current(date));
  }

  String get label => "${season.label} $year";

  @override
  bool operator ==(Object other) =>
      other is SeasonRef && other.year == year && other.season == season;

  @override
  int get hashCode => Object.hash(year, season);

  @override
  String toString() => label;
}

/// The sort order for the MAL seasonal anime endpoint.
enum AnimeSeasonSort {
  score("anime_score", "By Score"),
  popularity("anime_num_list_users", "By Popularity");

  const AnimeSeasonSort(this.apiValue, this.label);

  /// The value used by the MAL API.
  final String apiValue;

  /// A human-readable label.
  final String label;
}

/// A ranking category for the MAL anime ranking endpoint.
enum AnimeRankingType {
  all("all", "Top Anime"),
  airing("airing", "Top Airing"),
  upcoming("upcoming", "Top Upcoming"),
  tv("tv", "Top TV Series"),
  ova("ova", "Top OVA Series"),
  movie("movie", "Top Movies"),
  special("special", "Top Specials"),
  bypopularity("bypopularity", "Most Popular"),
  favorite("favorite", "Most Favorited");

  const AnimeRankingType(this.apiValue, this.label);

  /// The value used by the MAL API.
  final String apiValue;

  /// A human-readable label.
  final String label;
}

/// A ranking category for the MAL manga ranking endpoint.
enum MangaRankingType {
  all("all", "All"),
  manga("manga", "Top Manga"),
  novels("novels", "Top Novels"),
  oneshots("oneshots", "Top One-shots"),
  doujin("doujin", "Top Doujinshi"),
  manhwa("manhwa", "Top Manhwa"),
  manhua("manhua", "Top Manhua"),
  bypopularity("bypopularity", "Most Popular"),
  favorite("favorite", "Most Favorited");

  const MangaRankingType(this.apiValue, this.label);

  /// The value used by the MAL API.
  final String apiValue;

  /// A human-readable label.
  final String label;
}
