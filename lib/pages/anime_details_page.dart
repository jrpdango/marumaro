import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:miru/widgets/EpisodesWatchedPopup.dart';
import 'package:miru/widgets/ListStatusPopup.dart';
import 'package:miru/widgets/LoadingPopup.dart';
import 'package:miru/widgets/ScorePopup.dart';

class AnimeDetailsPage extends StatefulWidget {
  @override
  _AnimeDetailsPageState createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  bool detailChanged = false;
  OverlayEntry loadingOverlay;
  Function _callback;
  MALClient client;
  Map result;
  Map animeMap;
  bool netConnected;
  String chosenListStatus;
  String chosenScore;
  String chosenEpsWatched;
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

  /// Turns given [status] into valid text to send back through the MAL API.
  ///
  /// ```dart
  /// statusJSONify("Plan To Watch"); // plan_to_watch
  /// ```
  String statusJSONify(String status) {
    status = status.replaceAll(" ", "_").toLowerCase();
    return status;
  }

  void showOverlay(BuildContext context, String type) {
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
    switch (type) {
      case "status":
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
        break;
      case "episodes":
        overlayEntry = OverlayEntry(
            builder: (context) => Stack(children: <Widget>[
                  closer,
                  EpisodesWatchedPopup(
                    callback: (val) => setState(() => detailChanged = val),
                    numEpsChoice: (choice) =>
                        setState(() => chosenEpsWatched = choice),
                    totalEps: animeMap["node"]["num_episodes"],
                    overlayEntry: overlayEntry,
                  )
                ]));
        break;
      case "score":
        overlayEntry = OverlayEntry(
            builder: (context) => Stack(children: <Widget>[
                  closer,
                  ScorePopup(
                    callback: (val) => setState(() => detailChanged = val),
                    scoreChoice: (choice) =>
                        setState(() => chosenScore = choice),
                    overlayEntry: overlayEntry,
                  )
                ]));
        break;
      case "loading":
        overlayEntry = OverlayEntry(
            builder: (context) => Stack(
                  children: <Widget>[
                    Container(
                      color: Color.fromRGBO(38, 38, 38, 0.8),
                      height: this.result["deviceSize"].height,
                      width: this.result["deviceSize"].width,
                    ),
                    LoadingPopup(),
                  ],
                ));
        this.loadingOverlay = overlayEntry;
        break;
      default:
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
        break;
    }
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
    this.client = this.result["client"];
    this.chosenListStatus = animeMap["list_status"]["status"];
    this.chosenScore = "${animeMap["list_status"]["score"]}";
    this.chosenEpsWatched =
        "${animeMap["list_status"]["num_episodes_watched"]}";
    this._callback = this.result["callback"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              print("animeMap status: ${animeMap["list_status"]["status"]}");
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
                      showOverlay(context, "status");
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
                      showOverlay(context, "episodes");
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.remove_red_eye,
                          color: Colors.white,
                        ),
                        Text(
                          "${this.chosenEpsWatched}/${animeMap["node"]["num_episodes"]}",
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
                      showOverlay(context, "score");
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Text(
                          "${this.chosenScore}",
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
                  onPressed: () async {
                    showOverlay(context, "loading");
                    if (await this.client.updateList(UpdateListRequest(
                              animeID: "${this.animeMap["node"]["id"]}",
                              status: statusJSONify(this.chosenListStatus),
                              score: this.chosenScore,
                              episodesWatched: this.chosenEpsWatched,
                            )) ==
                        "200") {
                      print("Chosen score: ${this.chosenScore}");
                      print("List updated");
                      setState(() {
                        this.detailChanged = false;
                      });
                      Map newMap = animeMap;
                      newMap["list_status"]["status"] = this.chosenListStatus;
                      print(this.chosenListStatus);
                      _callback(newMap);
                    }
                    loadingOverlay.remove();
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
