class Anime {
  final int id;
  final String title;
  final Uri picture;
  final int totalEpisodes;
  final String showStatus;
  String userStatus;
  int userEpisodesWatched;
  int userScore;

  Anime({
    required this.id,
    required this.title,
    required this.picture,
    required this.totalEpisodes,
    required this.showStatus,
    required this.userStatus,
    required this.userEpisodesWatched,
    required this.userScore,
  });
}
