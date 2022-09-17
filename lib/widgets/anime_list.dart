import 'package:flutter/material.dart';
import 'package:miru/widgets/colored_tab_bar.dart';
import 'package:miru/widgets/custom_tabbarview_scroll_physics.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 35,
          child: ColoredTabBar(
            color: Colors.grey[900],
            tabBar: TabBar(
              controller: _tabController,
              tabs: const <Widget>[
                Tab(child: Text('Currently Watching')),
                Tab(child: Text('Plan To Watch')),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const CustomTabBarViewScrollPhysics(),
            children: const <Widget>[
              Text('Sarashi Mono'),
              Text('Tame no'),
            ],
          ),
        ),
      ],
    );
  }
}
