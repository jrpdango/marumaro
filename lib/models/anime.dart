class Anime {
  final int id;
  final String title;
  Uri? picture;
  final int totalEpisodes;
  final String showStatus;
  String? userStatus;
  int? userEpisodesWatched;
  int? userScore;

  Anime({
    required this.id,
    required this.title,
    this.picture,
    required this.totalEpisodes,
    required this.showStatus,
    this.userStatus,
    this.userEpisodesWatched,
    this.userScore,
  });
}
