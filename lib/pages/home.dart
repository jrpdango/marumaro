import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:miru/widgets/anime_list.dart';
import 'package:miru/widgets/browse.dart';
import 'package:miru/widgets/more.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/schedule.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/widgets/colored_tab_bar.dart';
import 'package:miru/widgets/list_container.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  MALClient _client = Get.find<GlobalController>().client.value;
  Map _getArgs = Get.arguments;
  Rx<int> _tabIndex = 0.obs;
  late List<ListContainer> _tabContents =
      getTabContents(_client.clientAnimeList);
  late bool _netConnected = _getArgs["connStatus"];
  late TabController _tabController;

  bool _hasTabBar = true;
  bool _hasSearch = true;

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _tabController = TabController(
      vsync: this,
      length: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Color.fromARGB(240, 0, 0, 0),
        child: Column(
          children: <Widget>[
            Text("This is the sidebar."),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextButton.icon(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('Are you sure you want to logout?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                Directory directory =
                                    await getApplicationDocumentsDirectory();
                                File("${directory.path}/miruTokens.json")
                                    .deleteSync();
                                Get.offNamed("/");
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('No'),
                            ),
                          ],
                        ),
                        barrierColor: Color.fromRGBO(38, 38, 38, 0.8),
                      );
                    },
                    icon: Icon(
                      Icons.logout_rounded,
                    ),
                    label: Text("Logout"),
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: _hasTabBar ? null : 80.0,
        bottom: _hasTabBar
            ? ColoredTabBar(
                color: Colors.grey[900]!,
                tabBar: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: createTabs(),
                ),
              )
            : null,
        flexibleSpace: _hasTabBar
            ? Image.asset(
                "assets/city.jpg",
                fit: BoxFit.cover,
                alignment: Alignment(0, -0.4),
              )
            : Image.asset(
                "assets/city.jpg",
                fit: BoxFit.cover,
                alignment: Alignment(0, -0.5),
              ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        actions: _hasSearch
            ? <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                    ),
                    onPressed: () {
                      Get.toNamed("/search");
                    },
                  ),
                ),
              ]
            : <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                ),
              ],
      ),
      body: tabs[_tabIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _tabIndex.value = index;
          if (index != 0) {
            setState(() {
              _hasTabBar = false;
              _hasSearch = false;
            });
          } else {
            setState(() {
              _hasTabBar = true;
              _hasSearch = true;
            });
          }
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
