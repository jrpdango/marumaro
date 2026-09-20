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
