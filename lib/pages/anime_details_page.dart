import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimeDetailsPage extends StatefulWidget {
  @override
  _AnimeDetailsPageState createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  Map result;
  Map animeMap;
  bool netConnected;
  List<String> animeInfoCategs = [
    "num_episodes",
    "status",
    "rank",
    "popularity",
    "source",
    "studios",
    "rating",
    "average_episode_duration"
  ];

  List<Widget> buildInfoList(List<String> categories) {
    List<Widget> infoRows = [];
    for (String element in this.animeInfoCategs) {
      infoRows.add(
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Container(
          height: 20.0,
          width: this.result["deviceWidth"] - 100,
          child: ListTile(
            leading: Text(
              "$element",
              style: TextStyle(color: Colors.white, fontSize: 10.0),
            ),
            trailing: Text("${animeMap["node"][element]}",
                style: TextStyle(color: Colors.white, fontSize: 10.0)),
          ),
        ),
      ]));
    }
    return infoRows;
  }

  @override
  void initState() {
    this.result = Get.arguments;
    this.netConnected = this.result["connStatus"];
    this.animeMap = this.result["animeMap"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: this.netConnected
                    ? FadeInImage.assetNetwork(
                        fit: BoxFit.cover,
                        height: 90,
                        width: 65,
                        placeholderCacheHeight: 90,
                        placeholderCacheWidth: 65,
                        placeholder: "assets/404img.png",
                        image: animeMap["node"]["main_picture"]["medium"],
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset("assets/404img.png"),
                      )
                    : Container(
                        height: 90,
                        width: 65,
                        child: Image.asset("assets/404img.png")),
              ),
              Container(
                width: this.result["deviceWidth"] - 85,
                child: Column(
                  children: [
                    Text(
                      animeMap["node"]["title"],
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Mean Score: ${animeMap["node"]["mean"]}" ??
                          "Score not found.",
                      style: TextStyle(color: Colors.amber, fontSize: 15.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: buildInfoList(this.animeInfoCategs),
          ),
        ],
      ),
    );
  }
}
