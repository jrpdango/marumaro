import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/manga_list_container.dart';
import 'package:miru/widgets/media_list_pager.dart';

/// The Manga tab: pages through the cached manga status buckets.
class MangaPage extends StatefulWidget {
  final TabController tabController;

  const MangaPage({super.key, required this.tabController});

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
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
