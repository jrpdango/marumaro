import 'package:flutter/material.dart';
import 'package:miru/widgets/custom_tabbarview_scroll_physics.dart';
import 'package:miru/widgets/list_container.dart';

class AnimeList extends StatelessWidget {
  final TabController tabController;
  final List<ListContainer> tabContents;
  const AnimeList({
    super.key,
    required this.tabContents,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      physics: CustomTabBarViewScrollPhysics(),
      controller: tabController,
      children: tabContents,
    );
  }
}
