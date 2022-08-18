import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/widgets/anime_list.dart';
import 'package:miru/widgets/browse.dart';
import 'package:miru/widgets/colored_tab_bar.dart';
import 'package:miru/widgets/main_appbar.dart';
import 'package:miru/widgets/main_drawer.dart';
import 'package:miru/widgets/more.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/schedule.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';

import 'package:miru/models/mal_client.dart';
import 'package:miru/widgets/list_container.dart';
import 'package:miru/enums/SearchType.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  MALClient _client = Get.find<GlobalController>().client;
  Map _getArgs = Get.arguments;
  Rx<int> _tabIndex = 0.obs;
  late List<ListContainer> _tabContents =
      getTabContents(_client.clientAnimeList);
  late bool _netConnected = _getArgs["connStatus"];
  late TabController _tabController;

  bool _hasTabBar = true;
  SearchType? _searchType = SearchType.local;

  late List<Widget> tabs = [
    AnimeList(
      tabController: _tabController,
      tabContents: _tabContents,
    ),
    Schedule(),
    Browse(),
    More(),
  ];

  /// Creates tabs for TabBar.
  ///
  List<Widget> createTabs() {
    List<String> tabNames = [
      "Currently Watching",
      "Plan To Watch",
      "Completed",
      "On Hold",
      "Dropped"
    ];
    List<Widget> menuTabs = [];
    for (int i = 0; i < 5; i++) {
      menuTabs.add(
        SizedBox(
          height: 30,
          child: Tab(
            child: Text(tabNames[i]),
          ),
        ),
      );
    }
    return menuTabs;
  }

  /// Initializes contents defined by [tabMap] for tabs in TabBar.
  ///
  List<ListContainer> getTabContents(Map tabMap) {
    List<String> tabNames = [
      "watching",
      "plan_to_watch",
      "completed",
      "on_hold",
      "dropped"
    ];
    List<ListContainer> tabContents = [];
    for (String tabName in tabNames) {
      tabContents.add(
        ListContainer(
          listType: tabName,
          connStatus: _netConnected,
        ),
      );
    }
    return tabContents;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: MainAppBar(
          searchType: _searchType,
        ),
      ),
      body: Column(
        children: [
          _hasTabBar
              ? ColoredTabBar(
                  color: Colors.grey[900]!,
                  tabBar: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: createTabs(),
                  ),
                )
              : SizedBox(),
          tabs[_tabIndex.value],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _tabIndex.value = index;
          switch (index) {
            // Home
            case 0:
              _hasTabBar = true;
              _searchType = SearchType.local;
              break;
            // Browse
            case 2:
              _hasTabBar = false;
              _searchType = SearchType.online;
              break;
            default:
              _hasTabBar = false;
              _searchType = null;
              break;
          }
          setState(() {});
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              backgroundColor: Colors.black87,
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              backgroundColor: Colors.black87,
              label: "Schedule"),
          BottomNavigationBarItem(
              icon: Icon(Icons.compass_calibration_rounded),
              backgroundColor: Colors.black87,
              label: "Browse"),
          BottomNavigationBarItem(
              icon: Icon(Icons.more),
              backgroundColor: Colors.black87,
              label: "More"),
        ],
      ),
    );
  }
}
