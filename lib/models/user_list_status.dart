import 'package:miru/enums/anime_list_type.dart';

class UserListStatus {
  AnimeListType? status;
  int? currentProgress;
  int? score;

  UserListStatus({
    this.status,
    this.currentProgress,
    this.score,
  });

  /// Creates a copy of this object with the given fields replaced with the new values.
  ///
  UserListStatus copyWith({
    AnimeListType? status,
    int? currentProgress,
    int? score,
  }) {
    return UserListStatus(
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      score: score ?? this.score,
    );
  }
}
