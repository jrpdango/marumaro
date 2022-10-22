import 'package:miru/enums/anime_airing_status.dart';
import 'package:miru/models/season.dart';

class Anime {
  final int id;
  final String title;
  final int totalEpisodes;
  final AnimeAiringStatus airingStatus;
  final Season season;
  Uri? pictureMedium;
  Uri? pictureLarge;
  String? userStatus;
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
}
