class Anime {
  final int id;
  final String title;
  final int totalEpisodes;
  final String airingStatus;
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
    this.pictureMedium,
    this.pictureLarge,
    this.userStatus,
    this.userEpisodesWatched,
    this.userScore,
  });
}
