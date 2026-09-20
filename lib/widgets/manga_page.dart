import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/manga_list_container.dart';
import 'package:miru/widgets/media_list_pager.dart';

/// The Manga tab: lazily loads the user's manga list and pages through the
/// status buckets.
class MangaPage extends StatefulWidget {
  final TabController tabController;

  const MangaPage({super.key, required this.tabController});

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  GlobalController? _controller;
  bool _requested = false;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    if (!_requested && !_controller!.mangaListLoaded) {
      _requested = true;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      await _controller!.loadMangaList();
      if (mounted) setState(() => _failed = false);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
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
    return ListenableBuilder(
      listenable: _controller!,
      builder: (BuildContext context, Widget? child) {
        if (_controller!.mangaListLoaded) {
          return MediaListPager(
            tabController: widget.tabController,
            tabContents: _createTabContents(),
          );
        }
        if (_failed) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  "Failed to load your manga list.",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _failed = false);
                    _load();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(color: Colors.white60),
        );
      },
    );
  }
}
