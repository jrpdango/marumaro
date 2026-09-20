import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/pages/manga_details_page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/media_list_card.dart';

class MangaListContainer extends StatefulWidget {
  /// An explicit list to display. When null, the controller's list for
  /// [mangaType] is shown instead.
  final List<Manga>? mangaList;
  final MangaListStatus? mangaType;

  const MangaListContainer({
    super.key,
    this.mangaType,
    this.mangaList,
  });

  @override
  State<MangaListContainer> createState() => _MangaListContainerState();
}

class _MangaListContainerState extends State<MangaListContainer> {
  GlobalController? _controller;

  List<Manga> get _mangaList {
    if (widget.mangaList != null) return widget.mangaList!;
    final MangaListStatus? status = widget.mangaType;
    if (status == null) return const <Manga>[];
    return _controller!.mangaLists[status] ?? const <Manga>[];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
  }

  Future<void> _refreshList() async {
    // Explicit lists (e.g. search results) are not backed by the controller.
    if (widget.mangaList != null) return;
    await _controller!.loadMangaList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller!,
      builder: (BuildContext context, Widget? child) {
        final List<Manga> mangaList = _mangaList;
        return RefreshIndicator(
          onRefresh: _refreshList,
          child: ListView.builder(
            key: PageStorageKey(
                "manga_${widget.mangaType?.apiValue ?? "search"}"),
            physics: const AlwaysScrollableScrollPhysics(),
            itemExtent: 106.0,
            itemCount: mangaList.length,
            itemBuilder: (context, index) {
              final Manga manga = mangaList[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                child: MediaListCard(
                  picture: manga.picture,
                  title: manga.title,
                  progress:
                      "${manga.userChaptersRead}/${manga.totalChapters}"
                      "  Vol ${manga.userVolumesRead}/${manga.totalVolumes}",
                  score: "${manga.userScore}",
                  statusLabel: manga.publishingStatus?.label ?? "",
                  statusPrefix: "Publishing Status",
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MangaDetailsPage(manga: manga),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
