import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/models/mal_client.dart';
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
  OverlayEntry? _loadingOverlay;
  final Function _callback = Get.arguments["callback"];
  final MALClient _client = Get.arguments["client"];
  final Map _animeMap = Get.arguments["animeMap"];
  bool _netConnected = Get.arguments["connStatus"];
  bool _detailChanged = false;
  late String _chosenListStatus = _animeMap["list_status"]["status"];
  late String _chosenScore = "${_animeMap["list_status"]["score"]}";
  late String _chosenEpsWatched =
      "${_animeMap["list_status"]["num_episodes_watched"]}";

  final Size _deviceSize = Get.arguments["deviceSize"];
  final List<String> _animeInfoCategs = [
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

  /// Generates an [OverlayEntry] with the given [popup].
  ///
  OverlayEntry createPopupOverlay(closer, popup) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          closer,
          popup,
        ],
      ),
    );
  }

  /// Defines behavior for updating list through API.
  ///
  void updateItem() async {
    showOverlay(context, "loading");
    if (await _client.updateList(
          UpdateListRequest(
            animeID: _animeMap["node"]["id"],
            status: statusJSONify(_chosenListStatus),
            score: _chosenScore,
            episodesWatched: _chosenEpsWatched,
          ),
        ) ==
        "200") {
      print("Chosen score: $_chosenScore");
      print("List updated");
      setState(
        () {
          this._detailChanged = false;
        },
      );

      // Locally set status/score/epsWatched before callback
      _animeMap["list_status"]["status"] = statusJSONify(_chosenListStatus);
      _animeMap["list_status"]["score"] = _chosenScore;
      _animeMap["list_status"]["num_episodes_watched"] = _chosenEpsWatched;

      _callback(_animeMap);
      _loadingOverlay!.remove();
    }
  }

  /// Shows an overlaying widget depending on the given [type].
  ///
  void showOverlay(BuildContext context, String type) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;
    final GestureDetector closer = GestureDetector(
      onTap: () {
        overlayEntry!.remove();
      },
      child: Container(
        color: Color.fromRGBO(38, 38, 38, 0.8),
        height: _deviceSize.height,
        width: _deviceSize.width,
      ),
    );

    switch (type) {
      case "status":
        overlayEntry = createPopupOverlay(
          closer,
          ListStatusPopup(
            callback: (val) => setState(() => _detailChanged = val),
            stringChoice: (choice) =>
                setState(() => _chosenListStatus = choice),
            closeOverlayCallback: () => overlayEntry!.remove(),
          ),
        );
        break;
      case "episodes":
        overlayEntry = createPopupOverlay(
          closer,
          EpisodesWatchedPopup(
            callback: (val) => setState(() => _detailChanged = val),
            numEpsChoice: (choice) =>
                setState(() => _chosenEpsWatched = choice),
            totalEps: _animeMap["node"]["num_episodes"],
            closeOverlayCallback: () => overlayEntry!.remove(),
          ),
        );
        break;
      case "score":
        overlayEntry = createPopupOverlay(
          closer,
          ScorePopup(
            callback: (val) => setState(() => _detailChanged = val),
            scoreChoice: (choice) => setState(() => _chosenScore = choice),
            initialScore: int.parse(_chosenScore),
            closeOverlayCallback: () => overlayEntry!.remove(),
          ),
        );
        break;
      case "loading":
        overlayEntry = OverlayEntry(
          builder: (context) => Stack(
            children: <Widget>[
              Container(
                color: Color.fromRGBO(38, 38, 38, 0.8),
                height: _deviceSize.height,
                width: _deviceSize.width,
              ),
              LoadingPopup(),
            ],
          ),
        );
        _loadingOverlay = overlayEntry;
        break;
      default:
        overlayEntry = createPopupOverlay(
          closer,
          ListStatusPopup(
            callback: (val) => setState(() => _detailChanged = val),
            stringChoice: (choice) =>
                setState(() => _chosenListStatus = choice),
            closeOverlayCallback: () => overlayEntry!.remove(),
          ),
        );
        break;
    }

    overlayState!.insert(overlayEntry);
  }

  /// Creates a [List] of [Widget]s that displays details for the currently selected anime.
  ///
  List<Widget> buildInfoList(List<String> categories) {
    List<Widget> infoRows = [];
    for (String element in categories) {
      infoRows.add(
        Container(
          height: 20.0,
          width: _deviceSize.width - 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Text>[
              Text(
                "$element",
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              ),
              Text(
                "${_animeMap["node"][element]}",
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            print("animeMap status: ${_animeMap["list_status"]["status"]}");
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: _netConnected
                    ? FadeInImage.assetNetwork(
                        fit: BoxFit.cover,
                        height: 90,
                        width: 65,
                        placeholderCacheHeight: 90,
                        placeholderCacheWidth: 65,
                        placeholder: "assets/404img.png",
                        image: _animeMap["node"]["main_picture"]["medium"],
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Container(
                                height: 90,
                                width: 65,
                                child: Image.asset("assets/404img.png")),
                      )
                    : Container(
                        height: 90,
                        width: 65,
                        child: Image.asset("assets/404img.png"),
                      ),
              ),
              Container(
                width: _deviceSize.width - 85,
                child: Column(
                  children: [
                    Text(
                      _animeMap["node"]["title"],
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Mean Score: ${_animeMap["node"]["mean"] ?? "Score not found."}",
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
                          _chosenListStatus,
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
                          "$_chosenEpsWatched/${_animeMap["node"]["num_episodes"]}",
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
                          "$_chosenScore",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Display a button if a change was made to update list item
          this._detailChanged
              ? TextButton(
                  onPressed: () {
                    updateItem();
                  },
                  child: Text("Update List"),
                )
              : SizedBox(height: 0, width: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: buildInfoList(_animeInfoCategs),
            ),
          ),
        ],
      ),
    );
  }
}
