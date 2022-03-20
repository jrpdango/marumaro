class AnimeDetails {
  final Uri url;
  final Map<String, Uri> mediumImageUrl;
  final Map<String, Uri> largeImageUrl;
  final String title;
  final String englishTitle;
  final String japaneseTitle;
  final List<String> titleSynonyms;
  final String type;
  final String source;
  final String totalEpisodes;
  final String showStatus;
  final String airedFromTo;
  final String episodeDuration;
  final String rating;
  final double meanScore;
  final int scoredBy;
  final int rank;
  final int popularity;
  final int members;
  final int favorites;
  final String synopsis;
  final String season;
  final int year;
  final List<Map<String, dynamic>> producers;

  AnimeDetails({
    required this.url,
    required this.mediumImageUrl,
    required this.largeImageUrl,
    required this.title,
    required this.englishTitle,
    required this.japaneseTitle,
    required this.titleSynonyms,
    required this.type,
    required this.source,
    required this.totalEpisodes,
    required this.showStatus,
    required this.airedFromTo,
    required this.episodeDuration,
    required this.rating,
    required this.meanScore,
    required this.scoredBy,
    required this.rank,
    required this.popularity,
    required this.members,
    required this.favorites,
    required this.synopsis,
    required this.season,
    required this.year,
    required this.producers,
  });
}
