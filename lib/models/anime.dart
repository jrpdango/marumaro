import 'dart:convert';

import 'package:miru/enums/anime_airing_status.dart';
import 'package:miru/enums/anime_list_type.dart';
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
  final int? userCurrentProgress;
  final int? userCurrentScore;

  @Transient()
  AnimeListType? userCurrentStatus;
  @Transient()
  Season? season;
  @Transient()
  AnimeAiringStatus? airingStatus;
  @Transient()
  Uri? pictureMedium;
  @Transient()
  Uri? pictureLarge;
  @Transient()
  UserListStatus? userStatus;

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

  int? get dbUserCurrentStatus {
    return userCurrentStatus?.index;
  }

  set dbUserCurrentStatus(int? value) {
    if (value != null) {
      userCurrentStatus = AnimeListType.values[value];
    }
  }

  @Transient()
  UserListStatus get userListStatus {
    return UserListStatus(
      status: userCurrentStatus,
      currentProgress: userCurrentProgress,
      score: userCurrentScore,
    );
  }

  @Transient()
  set userListStatus(UserListStatus? value) {
    userStatus = value;
  }

  Anime({
    this.id,
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
    this.userCurrentProgress,
    this.userCurrentScore,
    this.userCurrentStatus,
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
    int? userCurrentScore,
    int? userCurrentProgress,
    AnimeListType? userCurrentStatus,
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
      userCurrentScore: userCurrentScore ?? this.userCurrentScore,
      userCurrentProgress: userCurrentProgress ?? this.userCurrentProgress,
      userCurrentStatus: userCurrentStatus ?? this.userCurrentStatus,
    );
  }
}
