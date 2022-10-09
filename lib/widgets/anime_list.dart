import 'package:flutter/material.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/widgets/custom_tab_bar.dart';
import 'package:miru/widgets/custom_tabbarview_scroll_physics.dart';
import 'package:miru/widgets/list_container.dart';

class AnimeList extends StatefulWidget {
  const AnimeList({Key? key}) : super(key: key);

  @override
  State<AnimeList> createState() => _AnimeListState();
}

class _AnimeListState extends State<AnimeList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30,
          child: CustomTabBar(
            color: const Color(0xFF1C1C1C),
            tabBar: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const <Widget>[
                Tab(child: Text('Currently Watching')),
                Tab(child: Text('Plan To Watch')),
                Tab(child: Text('Completed')),
                Tab(child: Text('On Hold')),
                Tab(child: Text('Dropped')),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const CustomTabBarViewScrollPhysics(),
            children: const <Widget>[
              ListContainer(
                animeListType: AnimeListType.watching,
              ),
              ListContainer(
                animeListType: AnimeListType.planToWatch,
              ),
              ListContainer(
                animeListType: AnimeListType.completed,
              ),
              ListContainer(
                animeListType: AnimeListType.onHold,
              ),
              ListContainer(
                animeListType: AnimeListType.dropped,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
