import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/media_details/media_details_state.dart';

class MangaDetailsPage extends StatefulWidget {
  const MangaDetailsPage({super.key, required this.manga});

  final Manga manga;

  @override
  State<MangaDetailsPage> createState() => _MangaDetailsPageState();
}

class _MangaDetailsPageState extends State<MangaDetailsPage>
    with MediaDetailsStateMixin<MangaDetailsPage, MangaDetails> {
  Manga get _manga => widget.manga;

  @override
  GlobalController get controller => GlobalControllerScope.of(context);

  @override
  MediaKind get kind => MediaKind.manga;

  @override
  String get progressLabel => "Chapters";

  @override
  String get progressSheetLabel => "Chapters Read";

  @override
  int get totalProgress => _manga.totalChapters;

  @override
  int? get totalVolumes => _manga.totalVolumes;

  @override
  String get initialStatusValue => _manga.userStatus.apiValue;

  @override
  int get initialScore => _manga.userScore;

  @override
  int get initialProgress => _manga.userChaptersRead;

  @override
  int get initialVolumeProgress => _manga.userVolumesRead;

  @override
  int get mediaId => _manga.id;

  @override
  String get mediaTitle => _manga.title;

  @override
  Uri get mediaPicture => _manga.picture;

  @override
  String statusLabel(String apiValue) =>
      MangaListStatus.fromApiValue(apiValue).label;

  @override
  MediaDetailsData buildViewData(MangaDetails details) => details.toViewData(
        id: _manga.id,
        title: _manga.title,
        poster: _manga.picture,
      );

  @override
  UserListStatus? serverStatus(MangaDetails details) => details.myListStatus;

  @override
  Future<MangaDetails> loadDetails() =>
      controller.repository.fetchMangaDetails(_manga.id);

  @override
  Future<void> persistDraft({
    required String status,
    required int score,
    required int progress,
    int? volumes,
  }) {
    return controller.updateManga(
      manga: _manga,
      status: MangaListStatus.fromApiValue(status),
      score: score,
      chaptersRead: progress,
      volumesRead: volumes ?? _manga.userVolumesRead,
    );
  }

  @override
  Future<void> applyUserListStatus(
    UserListStatus status,
    Map<String, String> patch,
  ) {
    return controller.updateMangaUserListStatus(
      manga: _manga,
      status: status,
      patch: patch,
    );
  }

  @override
  Future<void> removeFromList() => controller.removeManga(_manga);

  @override
  Widget build(BuildContext context) => buildDetailsBody();
}
