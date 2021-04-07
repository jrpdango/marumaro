import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/widgets/ListStatusPopup.dart';

class AnimeDetailsPage extends StatefulWidget {
  @override
  _AnimeDetailsPageState createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  bool detailChanged = false;
  Map result;
  Map animeMap;
  bool netConnected;
  String chosenListStatus;
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

  void showStatusList(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    GestureDetector closer = GestureDetector(
        onTap: () {
          overlayEntry.remove();
        },
        child: Container(
          color: Color.fromRGBO(38, 38, 38, 0.8),
          height: this.result["deviceSize"].height,
          width: this.result["deviceSize"].width,
        ));
    overlayEntry = OverlayEntry(
        builder: (context) => Stack(children: <Widget>[
              closer,
              ListStatusPopup(
                callback: (val) => setState(() => detailChanged = val),
                stringChoice: (choice) =>
                    setState(() => chosenListStatus = choice),
                overlayEntry: overlayEntry,
              )
            ]));

    overlayState.insert(overlayEntry);
  }

  List<Widget> buildInfoList(List<String> categories) {
    List<Widget> infoRows = [];
    for (String element in this.animeInfoCategs) {
      infoRows.add(
        Container(
          height: 20.0,
          width: this.result["deviceSize"].width - 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Text>[
              Text(
                "$element",
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              ),
              Text(
                "${animeMap["node"][element]}",
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              )
            ],
          ),
        ),
      );
    }
    return infoRows;
  }

  @override
  void initState() {
    this.result = Get.arguments;
    this.netConnected = this.result["connStatus"];
    this.animeMap = this.result["animeMap"];
    this.chosenListStatus = animeMap["list_status"]["status"];
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
                            Container(
                                height: 90,
                                width: 65,
                                child: Image.asset("assets/404img.png")),
                      )
                    : Container(
                        height: 90,
                        width: 65,
                        child: Image.asset("assets/404img.png")),
              ),
              Container(
                width: this.result["deviceSize"].width - 85,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: () {
                      showStatusList(context);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                        ),
                        Text(
                          this.chosenListStatus,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: () {
                      print(detailChanged);
                      print(chosenListStatus);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.remove_red_eye,
                          color: Colors.white,
                        ),
                        Text(
                          "${animeMap["list_status"]["num_episodes_watched"]}/${animeMap["node"]["num_episodes"]}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Text(
                          "${animeMap["list_status"]["score"]}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          this.detailChanged
              ? TextButton(
                  onPressed: () {
                    // TODO
                    print("List updated");
                  },
                  child: Text("Update List"),
                )
              : SizedBox(height: 0, width: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: buildInfoList(this.animeInfoCategs),
            ),
          ),
        ],
      ),
    );
  }
}
