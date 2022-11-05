import 'dart:convert';

import 'package:miru/enums/anime_airing_status.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/models/season.dart';
import 'package:objectbox/objectbox.dart';
import 'package:miru/objectbox.g.dart';

@Entity()
class Anime {
  @Id()
  int? id;

  @Index()
  int animeId;

  final String title;
  final int totalEpisodes;
  final int? numListUsers;
  final int? numScoringUsers;
  final double? meanScore;
  final int? rank;
  final int? popularity;
  Season? season;
  AnimeAiringStatus? airingStatus;
  Uri? pictureMedium;
  Uri? pictureLarge;
  UserListStatus? userListStatus;

  // Converter for AnimeAiringStatus
  int? get dbAiringStatus {
    return airingStatus?.index;
  }

  set dbAiringStatus(int? value) {
    if (value != null) {
      airingStatus = AnimeAiringStatus.values[value];
    } else {
      airingStatus = null;
    }
  }

  // Converter for season
  String? get dbSeason {
    return jsonEncode([season?.name, season?.year]);
  }

  set dbSeason(String? value) {
    if (value != null) {
      List<dynamic> decodedSeason = jsonDecode(value);
      season = Season(
        name: decodedSeason[0],
        year: decodedSeason[1],
      );
    }
  }

  // Converter for pictureMedium
  String? get dbPictureMedium {
    return pictureMedium?.toString();
  }

  set dbPictureMedium(String? value) {
    if (value != null) {
      pictureMedium = Uri.parse(value);
    } else {
      pictureMedium = null;
    }
  }

  // Converter for pictureLarge
  String? get dbPictureLarge {
    return pictureLarge?.toString();
  }

  set dbPictureLarge(String? value) {
    if (value != null) {
      pictureLarge = Uri.parse(value);
    } else {
      pictureLarge = null;
    }
  }

  // Converter for userListStatus
  String? get dbUserListStatus {
    return jsonEncode([
      userListStatus?.currentProgress,
      userListStatus?.score,
      userListStatus?.status,
    ]);
  }

  set dbUserListStatus(String? value) {
    if (value != null) {
      List<dynamic> decodedUserListStatus = jsonDecode(value);
      userListStatus = UserListStatus(
        currentProgress: decodedUserListStatus[0],
        score: decodedUserListStatus[1],
        status: decodedUserListStatus[2],
      );
    }
  }

  Anime({
    required this.animeId,
    required this.title,
    required this.totalEpisodes,
    this.season,
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
