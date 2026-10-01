import 'package:marumaro/core/models/user_statistics.dart';

/// The authenticated MyAnimeList user.
class User {
  const User({
    required this.name,
    this.picture,
    this.animeStatistics,
    this.mangaStatistics,
  });

  final String name;
  final Uri? picture;

  /// Lifetime anime list aggregates, when requested from the API.
  final MediaStatistics? animeStatistics;

  /// Lifetime manga list aggregates, when requested from the API.
  final MediaStatistics? mangaStatistics;

  factory User.fromJson(Map<String, dynamic> json) {
    final String? picture = json["picture"] as String?;
    return User(
      name: (json["name"] as String?) ?? "",
      picture: picture == null ? null : Uri.tryParse(picture),
      animeStatistics: _statistics(
        json["anime_statistics"],
        MediaStatistics.fromAnimeJson,
      ),
      mangaStatistics: _statistics(
        json["manga_statistics"],
        MediaStatistics.fromMangaJson,
      ),
    );
  }

  static MediaStatistics? _statistics(
    dynamic value,
    MediaStatistics Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is Map) {
      return fromJson(value.cast<String, dynamic>());
    }
    return null;
  }
}
