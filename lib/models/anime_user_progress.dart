import 'package:miru/enums/anime_list_type.dart';

class AnimeUserProgress {
  AnimeListType? userStatus;
  int? userEpisodesWatched;
  int? userScore;

  AnimeUserProgress({
    this.userStatus,
    this.userEpisodesWatched,
    this.userScore,
  });

  /// Creates a copy of this object with the given fields replaced with the new values.
  ///
  AnimeUserProgress copyWith({
    AnimeListType? userStatus,
    int? userEpisodesWatched,
    int? userScore,
  }) {
    return AnimeUserProgress(
      userStatus: userStatus ?? this.userStatus,
      userEpisodesWatched: userEpisodesWatched ?? this.userEpisodesWatched,
      userScore: userScore ?? this.userScore,
    );
  }
}
