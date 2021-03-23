import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:miru/services/anime_search_request.dart';
import 'package:miru/services/anime_details_request.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/delete_anime_request.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/widgets/ColoredTabBar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map result;
  List<dynamic> animeList;
  MALClient client;
  bool netConnected = false;

  MALClient assignClient() => result["client"];

  List<dynamic> setupList() => result["anime_list"];

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

  Future<void> refreshList() async {
    Map result = await this.client.getAnimeList(AnimeListRequest());
    bool checkConn = await DataConnectionChecker().hasConnection;
    // print(result["data"]);
    // print(result["data"].runtimeType);
    setState(() {
      this.animeList = result["data"];
      this.netConnected = checkConn;
    });
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

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    this.result = Get.arguments;
    this.client = this.assignClient();
    this.animeList = this.setupList();
    this.testConnection();
    // this.refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton(
          child: Text("Update List"),
          onPressed: () {
            this.refreshList();
          },
        ),
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
            SafeArea(
              top: false,
              child: ListView.builder(
                  itemCount: animeList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: Card(
                        color: Colors.grey[900],
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0)),
                              child: this.netConnected
                                  ? FadeInImage.assetNetwork(
                                      fit: BoxFit.cover,
                                      height: 90,
                                      placeholder: "assets/404img.png",
                                      image: animeList[index]["node"]
                                          ["main_picture"]["medium"],
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset("assets/404img.png"),
                                    )
                                  : Image.asset("assets/404img.png"),
                            ),
                            Text("${animeList[index]["node"]["title"]}",
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            Center(
                child: Text("Plan To Watch",
                    style: TextStyle(color: Colors.white))),
            Center(
                child:
                    Text("Completed", style: TextStyle(color: Colors.white))),
            Center(
                child: Text("On Hold", style: TextStyle(color: Colors.white))),
            Center(
                child: Text("Dropped", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
