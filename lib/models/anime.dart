import 'package:miru/enums/anime_airing_status.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/models/season.dart';
import 'package:miru/objectbox.g.dart';

@Entity()
class Anime {
  @Id()
  int? id;

  @Index()
  int animeId;

  final String title;
  final int totalEpisodes;
  final Season season;
  final AnimeAiringStatus? airingStatus;
  final int? numListUsers;
  final int? numScoringUsers;
  final double? meanScore;
  final int? rank;
  final int? popularity;
  Uri? pictureMedium;
  Uri? pictureLarge;
  UserListStatus? userListStatus;

  Anime({
    required this.animeId,
    required this.title,
    required this.totalEpisodes,
    required this.season,
    this.airingStatus,
    this.numListUsers,
    this.numScoringUsers,
    this.meanScore,
    this.rank,
    this.popularity,
    this.pictureMedium,
    this.pictureLarge,
    this.userListStatus,
  });

  /// Creates a copy of this object with the given fields replaced with the new values.
  ///
  Anime copyWith({
    int? animeId,
    String? title,
    int? totalEpisodes,
    Season? season,
    AnimeAiringStatus? airingStatus,
    int? numListUsers,
    int? numScoringUsers,
    double? meanScore,
    int? rank,
    int? popularity,
    Uri? pictureMedium,
    Uri? pictureLarge,
    UserListStatus? userListStatus,
  }) {
    return Anime(
      animeId: animeId ?? this.animeId,
      title: title ?? this.title,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      season: season ?? this.season,
      airingStatus: airingStatus ?? this.airingStatus,
      numListUsers: numListUsers ?? this.numListUsers,
      numScoringUsers: numScoringUsers ?? this.numScoringUsers,
      meanScore: meanScore ?? this.meanScore,
      rank: rank ?? this.rank,
      popularity: popularity ?? this.popularity,
      pictureMedium: pictureMedium ?? this.pictureMedium,
      pictureLarge: pictureLarge ?? this.pictureLarge,
      userListStatus:
          userListStatus?.copyWith() ?? this.userListStatus?.copyWith(),
    );
  }
}
