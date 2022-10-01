class Anime {
  final int id;
  final String title;
  final int totalEpisodes;
  final String showStatus;
  Uri? pictureMedium;
  Uri? pictureLarge;
  String? userStatus;
  int? userEpisodesWatched;
  int? userScore;

  Anime({
    required this.id,
    required this.title,
    required this.totalEpisodes,
    required this.showStatus,
    this.pictureMedium,
    this.pictureLarge,
    this.userStatus,
    this.userEpisodesWatched,
    this.userScore,
  });
}
