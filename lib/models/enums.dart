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
