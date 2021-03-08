import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/services/anime_search_request.dart';
import 'package:miru/services/anime_details_request.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/delete_anime_request.dart';
import 'package:miru/services/mal_client.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

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

  @override
  void initState() {
    super.initState();
    this.result = Get.arguments;
    this.client = this.assignClient();
    this.animeList = this.setupList();
    this.testConnection();
    // this.refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text("Update List"),
        onPressed: () {
          this.refreshList();
        },
      ),
      body: SafeArea(
        top: false,
        child: ListView.builder(
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(10.0),
                child: Card(
                  child: ListTile(
                    title: Text("${animeList[index]["node"]["title"]}"),
                    leading: this.netConnected
                        ? FadeInImage.assetNetwork(
                            placeholder: "assets/404img.png",
                            image: animeList[index]["node"]["main_picture"]
                                ["medium"],
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/404img.png"),
                          )
                        : Image.asset("assets/404img.png"),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
