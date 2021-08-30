import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/anime_search_request.dart';
import 'package:miru/services/anime_details_request.dart';
import 'package:miru/services/delete_anime_request.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/widgets/ColoredTabBar.dart';
import 'package:miru/widgets/ListContainer.dart';

class Home extends StatefulWidget {
  final Map animeMap;
  final MALClient client;

  const Home({Key key, this.animeMap, this.client}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map result;
  Map animeMap;
  List<ListContainer> _tabContents;
  bool netConnected = false;

  Map setupAnimeMap() => result["anime_map"];

  Future<void> searchAnime(String query,
      {String limit, String offset, String fields}) async {
    print(await widget.client.animeSearch(AnimeSearchRequest(
        query: query, limit: limit, offset: offset, fields: fields)));
  }

  Future<void> getAnimeDetails(String animeID, {String fields}) async {
    print(await widget.client.getAnimeDetails(
        AnimeDetailsRequest(animeID: animeID, fields: fields)));
  }

  Future<void> deleteAnime(String animeID) async {
    await widget.client.deleteAnime(DeleteAnimeRequest(animeID: animeID));
  }

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
      menuTabs.add(SizedBox(height: 30, child: Tab(child: Text(tabNames[i]))));
    }
    return menuTabs;
  }

  List<ListContainer> getTabContents(Map newMap) {
    List<String> tabNames = [
      "watching",
      "plan_to_watch",
      "completed",
      "on_hold",
      "dropped"
    ];
    List<ListContainer> tabContents = [];
    for (String tabName in tabNames) {
      // print("getTabContents animeList: ${newMap[tabName]}");
      tabContents.add(ListContainer(
          animeMapCallback: (val) {
            setState(() => this.animeMap = val);
            this.refreshListLocal();
          },
          animeList: newMap[tabName],
          client: widget.client,
          listType: tabName,
          connStatus: this.netConnected));
    }
    return tabContents;
  }

  // Used to update list on initialization
  Future<void> refreshList() async {
    Map result = await widget.client.getAnimeList(AnimeListRequest());
    bool checkConn = await DataConnectionChecker().hasConnection;
    // print(result);
    // print(result["data"].runtimeType);
    setState(() {
      this.animeMap = result;
      this.netConnected = checkConn;
      this._tabContents = getTabContents(result);
    });
  }

  // Used to update list when app is already in use
  Future<void> refreshListLocal() async {
    bool checkConn = await DataConnectionChecker().hasConnection;
    setState(() {
      this.netConnected = checkConn;
      this._tabContents = getTabContents(this.animeMap);
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    this.result = Get.arguments;
    this.animeMap = widget.animeMap;
    this.netConnected = result["connStatus"];
    _tabContents = [
      ListContainer(
          animeMapCallback: (val) {
            setState(() => this.animeMap = val);
          },
          animeList: this.animeMap["watching"] ?? [],
          client: widget.client,
          listType: "watching",
          connStatus: this.netConnected),
      ListContainer(
          animeMapCallback: (val) {
            setState(() => this.animeMap = val);
          },
          animeList: this.animeMap["plan_to_watch"] ?? [],
          client: widget.client,
          listType: "plan_to_watch",
          connStatus: this.netConnected),
      ListContainer(
          animeMapCallback: (val) {
            setState(() => this.animeMap = val);
          },
          animeList: this.animeMap["completed"] ?? [],
          client: widget.client,
          listType: "completed",
          connStatus: this.netConnected),
      ListContainer(
          animeMapCallback: (val) {
            setState(() => this.animeMap = val);
          },
          animeList: this.animeMap["on_hold"] ?? [],
          client: widget.client,
          listType: "on_hold",
          connStatus: this.netConnected),
      ListContainer(
          animeMapCallback: (val) {
            setState(() => this.animeMap = val);
          },
          animeList: this.animeMap["dropped"] ?? [],
          client: widget.client,
          listType: "dropped",
          connStatus: this.netConnected)
    ];
    this.refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          bottom: ColoredTabBar(
            color: Colors.grey[900],
            tabBar: TabBar(
              isScrollable: true,
              tabs: this.createTabs(),
            ),
          ),
          flexibleSpace: Image.asset("assets/lofigirl.jpg", fit: BoxFit.cover),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {})
          ],
        ),
        body: TabBarView(
          children: _tabContents,
        ),
        bottomNavigationBar: BottomNavigationBar(
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
                icon: Icon(Icons.person),
                backgroundColor: Colors.black87,
                label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.more),
                backgroundColor: Colors.black87,
                label: "More"),
          ],
        ),
      ),
    );
  }
}
