import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/library/manga_list_container.dart';
import 'package:marumaro/features/library/media_list_pager.dart';

/// The Manga tab: pages through the cached manga status buckets.
class MangaTab extends StatefulWidget {
  final TabController tabController;

  const MangaTab({super.key, required this.tabController});

  @override
  State<MangaTab> createState() => _MangaTabState();
}

class _MangaTabState extends State<MangaTab> {
  GlobalController? _controller;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    if (!_requested &&
        !_controller!.mangaSynced &&
        !_controller!.mangaSyncing) {
      _requested = true;
      _controller!.syncManga();
    }
  }

  /// Creates the list views shown by each status tab.
  List<MangaListContainer> _createTabContents() {
    return MangaListStatus.values
        .map((MangaListStatus status) => MangaListContainer(mangaType: status))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MediaListPager(
      tabController: widget.tabController,
      tabContents: _createTabContents(),
    );
  }
}
