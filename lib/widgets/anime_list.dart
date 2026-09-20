import 'package:flutter/material.dart';
import 'package:miru/widgets/list_container.dart';
import 'package:miru/widgets/tab_page_scroll_physics.dart';

/// A horizontally paged view of the status lists, kept in sync with [tabController].
///
/// Replaces [TabBarView] so the paging physics can be controlled. [TabBarView]
/// always wraps the supplied physics in [PageScrollPhysics], whose velocity
/// threshold makes swipes inconsistent; here the [PageView] uses
/// [TabPageScrollPhysics] directly via `pageSnapping: false`.
class AnimeList extends StatefulWidget {
  final TabController tabController;
  final List<ListContainer> tabContents;

  const AnimeList({
    super.key,
    required this.tabContents,
    required this.tabController,
  });

  @override
  State<AnimeList> createState() => _AnimeListState();
}

class _AnimeListState extends State<AnimeList> {
  late final PageController _pageController;
  late int _lastTabIndex;

  /// Direction of the in-progress drag, exposed to the physics.
  double _dragDirection = 0.0;

  /// True while the pager is animating because a tab was tapped, so the
  /// resulting [PageView.onPageChanged] callbacks do not feed back into the
  /// [TabController].
  bool _animatingToTab = false;

  @override
  void initState() {
    super.initState();
    _lastTabIndex = widget.tabController.index;
    _pageController = PageController(initialPage: _lastTabIndex);
    widget.tabController.addListener(_handleTabController);
  }

  @override
  void didUpdateWidget(AnimeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_handleTabController);
      widget.tabController.addListener(_handleTabController);
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabController);
    _pageController.dispose();
    super.dispose();
  }

  /// Follows tab taps: when the [TabController] animates to a new index, move
  /// the pager to match.
  void _handleTabController() {
    final int index = widget.tabController.index;
    if (index == _lastTabIndex) return;
    _lastTabIndex = index;
    if (!widget.tabController.indexIsChanging || !_pageController.hasClients) {
      return;
    }
    _animatingToTab = true;
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        )
        .whenComplete(() {
      if (mounted) _animatingToTab = false;
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _animatingToTab = false;
    } else if (notification is ScrollUpdateNotification) {
      final double delta = notification.scrollDelta ?? 0.0;
      if (notification.dragDetails != null && delta != 0.0) {
        _dragDirection = delta.sign;
      }
    } else if (notification is ScrollEndNotification) {
      _dragDirection = 0.0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: PageView(
        controller: _pageController,
        pageSnapping: false,
        physics: TabPageScrollPhysics(dragDirection: () => _dragDirection),
        onPageChanged: (int index) {
          if (!_animatingToTab && widget.tabController.index != index) {
            widget.tabController.index = index;
          }
        },
        children: widget.tabContents,
      ),
    );
  }
}
