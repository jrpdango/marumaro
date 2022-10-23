import 'package:miru/enums/anime_airing_status.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/models/season.dart';

class Anime {
  final int id;
  final String title;
  final int totalEpisodes;
  final AnimeAiringStatus airingStatus;
  final Season season;
  Uri? pictureMedium;
  Uri? pictureLarge;
  AnimeListType? userStatus;
  int? userEpisodesWatched;
  int? userScore;

  Anime({
    required this.id,
    required this.title,
    required this.totalEpisodes,
    required this.airingStatus,
    required this.season,
    this.pictureMedium,
    this.pictureLarge,
    this.userStatus,
    this.userEpisodesWatched,
    this.userScore,
  });

  /// Creates a copy of this object with the given fields replaced with the new values.
  ///
  Anime copyWith({
    int? id,
    String? title,
    int? totalEpisodes,
    AnimeAiringStatus? airingStatus,
    Season? season,
    Uri? pictureMedium,
    Uri? pictureLarge,
    AnimeListType? userStatus,
    int? userEpisodesWatched,
    int? userScore,
  }) {
    return Anime(
      id: id ?? this.id,
      title: title ?? this.title,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      airingStatus: airingStatus ?? this.airingStatus,
      season: season ?? this.season,
      pictureMedium: pictureMedium ?? this.pictureMedium,
      pictureLarge: pictureLarge ?? this.pictureLarge,
      userStatus: userStatus ?? this.userStatus,
      userEpisodesWatched: userEpisodesWatched ?? this.userEpisodesWatched,
      userScore: userScore ?? this.userScore,
    );
  }
}
