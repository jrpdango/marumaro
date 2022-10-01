import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/services/anime_details_request.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/services/text_cleaner.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:miru/widgets/episodes_watched_popup.dart';
import 'package:miru/widgets/list_status_popup.dart';
import 'package:miru/widgets/loading_popup.dart';
import 'package:miru/widgets/score_popup.dart';

class AnimeDetailsPage extends StatefulWidget {
  @override
  _AnimeDetailsPageState createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  MALClient _client = Get.find<GlobalController>().client;
  final Function _callback = Get.arguments["callback"];
  final Anime _anime = Get.arguments["anime"];
  bool _netConnected = Get.arguments["connStatus"];
  bool _detailChanged = false;
  late Rx<String> _chosenListStatus =
      TextCleaner.unjsonify(_anime.userStatus!).obs;
  late Rx<int> _chosenScore = _anime.userScore!.obs;
  late Rx<int> _chosenEpsWatched = _anime.userEpisodesWatched!.obs;
  late Future<Map<String, dynamic>> _animeDetails = getAnimeDetails();

  final Size _deviceSize = Get.arguments["deviceSize"];

  /// Defines behavior for updating list through API.
  ///
  void updateItem() async {
    showOverlay(context, "loading");
    if (await _client.updateList(
          UpdateListRequest(
            animeID: _anime.id,
            status: TextCleaner.jsonify(_chosenListStatus.value),
            score: _chosenScore.value.toString(),
            episodesWatched: _chosenEpsWatched.toString(),
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
      _anime.userStatus = TextCleaner.jsonify(_chosenListStatus.value);
      _anime.userScore = _chosenScore.value;
      _anime.userEpisodesWatched = _chosenEpsWatched.value;

      _callback(_anime);
      // Remove loading overlay
      Get.back();
    }
  }

  /// Shows an overlaying widget depending on the given [type].
  ///
  void showOverlay(BuildContext context, String type) {
    switch (type) {
      case 'status':
        Get.dialog(
          ListStatusPopup(
            statusChoice: _chosenListStatus,
            detailChangedCallback: (val) {
              setState(() => _detailChanged = val);
            },
            closeOverlayCallback: () => Get.back(),
          ),
          barrierColor: Color.fromRGBO(38, 38, 38, 0.8),
        );
        break;
      case 'episodes':
        Get.dialog(
          EpisodesWatchedPopup(
            callback: (val) => setState(() => _detailChanged = val),
            numEpsChoice: _chosenEpsWatched,
            totalEps: _anime.totalEpisodes,
            closeOverlayCallback: () => Get.back(),
          ),
          barrierColor: Color.fromRGBO(38, 38, 38, 0.8),
        );
        break;
      case 'score':
        Get.dialog(
          ScorePopup(
            detailChangedCallback: (val) =>
                setState(() => _detailChanged = val),
            scoreChoice: _chosenScore,
            closeOverlayCallback: () => Get.back(),
          ),
          barrierColor: Color.fromRGBO(38, 38, 38, 0.8),
        );
        break;
      case 'loading':
        Get.dialog(
          LoadingPopup(),
        );
        break;
    }
  }

  /// Creates a [List] of [Widget]s that displays details for the currently selected anime.
  ///
  List<Widget> buildInfoList(Map<String, dynamic> animeDetails) {
    const List<String> categories = [
      "num_episodes",
      "status",
      "start_date",
      "end_date",
      "rank",
      "popularity",
      "source",
      "rating",
      "average_episode_duration",
    ];
    // If loading, show spinkit
    if (animeDetails.length == 1)
      return <Widget>[
        SpinKitPulse(
          color: Colors.amber,
        )
      ];
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
                TextCleaner.unjsonify(element),
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              ),
              Text(
                TextCleaner.unjsonify("${animeDetails[element]}"),
                style: TextStyle(color: Colors.white, fontSize: 10.0),
                overflow: TextOverflow.clip,
              )
            ],
          ),
        ),
      );
    }
    return infoRows;
  }

  /// Retrieve anime details for the corresponding [Anime].
  ///
  Future<Map<String, dynamic>> getAnimeDetails() async {
    return await _client
        .getAnimeDetails(AnimeDetailsRequest(animeID: _anime.id));
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
            print("animeMap status: ${_anime.userStatus}");
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
                        image: _anime.picture.toString(),
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
                      _anime.title,
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FutureBuilder(
                      future: _animeDetails,
                      initialData: {"mean": "Loading data."},
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        Text text = Text("");
                        if (snapshot.hasData) {
                          text = Text(
                            "Mean Score: ${snapshot.data["mean"]}",
                            style:
                                TextStyle(color: Colors.amber, fontSize: 15.0),
                          );
                        } else if (snapshot.hasError) {
                          text = Text(
                              "Error loading data. Please try again later.");
                        }
                        return text;
                      },
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
                      showOverlay(context, 'status');
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                        ),
                        Text(
                          TextCleaner.unjsonify(_chosenListStatus.value),
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
                          "$_chosenEpsWatched/${_anime.totalEpisodes}",
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
            child: FutureBuilder(
              future: _animeDetails,
              initialData: {"loading": true},
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List<Widget> children = <Widget>[];
                if (snapshot.hasData) {
                  children = buildInfoList(snapshot.data);
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    Text("Error loading data. Please try again later."),
                  ];
                }
                return Column(
                  children: children,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
