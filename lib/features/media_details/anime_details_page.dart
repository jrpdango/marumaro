import 'package:flutter/material.dart';
import 'package:tamarun/core/core.dart';
import 'package:tamarun/features/media_details/media_details_state.dart';

class AnimeDetailsPage extends StatefulWidget {
  const AnimeDetailsPage({super.key, required this.anime});

  final Anime anime;

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage>
    with MediaDetailsStateMixin<AnimeDetailsPage, AnimeDetails> {
  Anime get _anime => widget.anime;

  @override
  GlobalController get controller => GlobalControllerScope.of(context);

  @override
  MediaKind get kind => MediaKind.anime;

  @override
  String get progressLabel => "Episodes";

  @override
  String get progressSheetLabel => "Episodes Watched";

  @override
  int get totalProgress => _anime.totalEpisodes;

  @override
  int? get totalVolumes => null;

  @override
  String get initialStatusValue => _anime.userStatus.apiValue;

  @override
  int get initialScore => _anime.userScore;

  @override
  int get initialProgress => _anime.userEpisodesWatched;

  @override
  int get initialVolumeProgress => 0;

  @override
  bool get initialInList => _anime.inList;

  @override
  int get mediaId => _anime.id;

  @override
  String get mediaTitle => _anime.title;

  @override
  Uri get mediaPicture => _anime.picture;

  @override
  String statusLabel(String apiValue) =>
      AnimeListStatus.fromApiValue(apiValue).label;

  @override
  MediaDetailsData buildViewData(AnimeDetails details) => details.toViewData(
        id: _anime.id,
        title: _anime.title,
        poster: _anime.picture,
      );

  @override
  UserListStatus? serverStatus(AnimeDetails details) => details.myListStatus;

  @override
  Future<AnimeDetails> loadDetails() =>
      controller.repository.fetchAnimeDetails(_anime.id);

  @override
  Future<void> persistDraft({
    required String status,
    required int score,
    required int progress,
    int? volumes,
  }) {
    return controller.updateAnime(
      anime: _anime,
      status: AnimeListStatus.fromApiValue(status),
      score: score,
      episodesWatched: progress,
    );
  }

  @override
  Future<void> applyUserListStatus(
    UserListStatus status,
    Map<String, String> patch,
  ) {
    return controller.updateAnimeUserListStatus(
      anime: _anime,
      status: status,
      patch: patch,
    );
  }

  @override
  Future<void> removeFromList() => controller.removeAnime(_anime);

  @override
  Widget build(BuildContext context) => buildDetailsBody();
}
