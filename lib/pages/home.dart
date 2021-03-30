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
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map result;
  Map animeMap;
  MALClient client;
  bool netConnected = false;

  MALClient assignClient() => result["client"];

  Map setupAnimeMap() => result["anime_map"];

  Future<void> searchAnime(String query,
      {String limit, String offset, String fields}) async {
    print(await this.client.animeSearch(AnimeSearchRequest(
        query: query, limit: limit, offset: offset, fields: fields)));
  }

  Future<void> getAnimeDetails(String animeID, {String fields}) async {
    print(await this.client.getAnimeDetails(
        AnimeDetailsRequest(animeID: animeID, fields: fields)));
  }

  Future<void> deleteAnime(String animeID) async {
    await this.client.deleteAnime(DeleteAnimeRequest(animeID: animeID));
  }

  Future<void> testConnection() async {
    bool checkConn = await DataConnectionChecker().hasConnection;
    setState(() {
      this.netConnected = checkConn;
    });
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

  Future<void> refreshList() async {
    Map result = await this.client.getAnimeList(AnimeListRequest());
    bool checkConn = await DataConnectionChecker().hasConnection;
    // print(result);
    // print(result["data"].runtimeType);
    setState(() {
      this.animeMap = result;
      this.netConnected = checkConn;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    this.result = Get.arguments;
    this.client = this.assignClient();
    this.animeMap = this.setupAnimeMap();
    this.testConnection();
    // this.refreshList();
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
          children: [
            RefreshIndicator(
              onRefresh: () => this.refreshList(),
              child: ListContainer(
                  animeList: this.animeMap["watching"],
                  client: this.client,
                  listType: "watching",
                  connStatus: this.netConnected),
            ),
            RefreshIndicator(
              onRefresh: () => this.refreshList(),
              child: ListContainer(
                  animeList: this.animeMap["plan_to_watch"],
                  client: this.client,
                  listType: "plan_to_watch",
                  connStatus: this.netConnected),
            ),
            RefreshIndicator(
              onRefresh: () => this.refreshList(),
              child: ListContainer(
                  animeList: this.animeMap["completed"],
                  client: this.client,
                  listType: "completed",
                  connStatus: this.netConnected),
            ),
            RefreshIndicator(
              onRefresh: () => this.refreshList(),
              child: ListContainer(
                  animeList: this.animeMap["on_hold"],
                  client: this.client,
                  listType: "on_hold",
                  connStatus: this.netConnected),
            ),
            RefreshIndicator(
              onRefresh: () => this.refreshList(),
              child: ListContainer(
                  animeList: this.animeMap["dropped"],
                  client: this.client,
                  listType: "dropped",
                  connStatus: this.netConnected),
            ),
            // Center(
            //     child: Text("Dropped", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
