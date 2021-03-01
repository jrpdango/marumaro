import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/services/anime_search_request.dart';
import 'package:miru/services/mal_client.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map result;
  List<Map> animeList = List();
  MALClient client;

  MALClient assignClient() => result["client"];

  List<Map> setupList() => result["anime_list"];

  Future<void> testSearch() async {
    print(await this.client.animeSearch(AnimeSearchRequest(query: "clannad")));
  }

  @override
  void initState() {
    super.initState();
    this.result = Get.arguments;
    this.animeList = this.setupList();
    this.client = this.assignClient();
    this.testSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    leading: Image.network(
                        animeList[index]["node"]["main_picture"]["medium"]),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
