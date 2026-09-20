import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  const AnimeDetailsPage({Key? key, required this.anime}) : super(key: key);

  final Anime anime;

  @override
  _AnimeDetailsPageState createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  GlobalController? _controller;
  MALClient? _client;

  bool _detailChanged = false;
  late String _chosenListStatus = widget.anime.userStatus;
  late String _chosenScore = "${widget.anime.userScore}";
  late String _chosenEpsWatched = "${widget.anime.userEpisodesWatched}";
  Future<Map<String, dynamic>>? _animeDetails;

  Anime get _anime => widget.anime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    _client ??= _controller!.client;
    _animeDetails ??= _getAnimeDetails();
  }

  /// Defines behavior for updating list through API.
  Future<void> _updateItem() async {
    _showOverlay("loading");
    final String result = await _client!.updateList(
      UpdateListRequest(
        animeID: _anime.id,
        status: TextCleaner.jsonify(_chosenListStatus),
        score: _chosenScore,
        episodesWatched: _chosenEpsWatched,
      ),
    );
    if (!mounted) return;
    if (result == "200") {
      final String oldStatus = _anime.userStatus;
      _anime.userStatus = TextCleaner.jsonify(_chosenListStatus);
      _anime.userScore = int.parse(_chosenScore);
      _anime.userEpisodesWatched = int.parse(_chosenEpsWatched);
      _controller!.moveAnime(_anime, oldStatus, _anime.userStatus);
      setState(() => _detailChanged = false);
    }
    // Dismiss the loading overlay.
    Navigator.of(context).pop();
  }

  /// Shows an overlaying widget depending on the given [type].
  void _showOverlay(String type) {
    switch (type) {
      case 'status':
        showDialog(
          context: context,
          barrierColor: const Color.fromRGBO(38, 38, 38, 0.8),
          builder: (_) => ListStatusPopup(
            callback: (val) => setState(() => _detailChanged = val),
            stringChoice: (choice) => setState(() => _chosenListStatus = choice),
            closeOverlayCallback: () => Navigator.of(context).pop(),
          ),
        );
        break;
      case 'episodes':
        showDialog(
          context: context,
          barrierColor: const Color.fromRGBO(38, 38, 38, 0.8),
          builder: (_) => EpisodesWatchedPopup(
            callback: (val) => setState(() => _detailChanged = val),
            numEpsChoice: (choice) => setState(() => _chosenEpsWatched = choice),
            totalEps: _anime.totalEpisodes,
            closeOverlayCallback: () => Navigator.of(context).pop(),
          ),
        );
        break;
      case 'score':
        showDialog(
          context: context,
          barrierColor: const Color.fromRGBO(38, 38, 38, 0.8),
          builder: (_) => ScorePopup(
            callback: (val) => setState(() => _detailChanged = val),
            scoreChoice: (choice) => setState(() => _chosenScore = choice),
            initialScore: int.parse(_chosenScore),
            closeOverlayCallback: () => Navigator.of(context).pop(),
          ),
        );
        break;
      case 'loading':
        showDialog(
          context: context,
          builder: (_) => const LoadingPopup(),
        );
        break;
    }
  }

  /// Creates a [List] of [Widget]s that displays details for the selected anime.
  List<Widget> _buildInfoList(Map<String, dynamic> animeDetails, Size size) {
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
    if (animeDetails.length == 1) {
      return <Widget>[
        const SpinKitPulse(color: Colors.amber),
      ];
    }
    final List<Widget> infoRows = [];
    for (String element in categories) {
      infoRows.add(
        SizedBox(
          height: 20.0,
          width: size.width - 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Text>[
              Text(
                TextCleaner.unjsonify(element),
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              ),
              Text(
                TextCleaner.unjsonify("${animeDetails[element]}"),
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      );
    }
    return infoRows;
  }

  /// Retrieves anime details for the corresponding [Anime].
  Future<Map<String, dynamic>> _getAnimeDetails() async {
    return await _client!
        .getAnimeDetails(AnimeDetailsRequest(animeID: _anime.id));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FadeInImage.assetNetwork(
                  fit: BoxFit.cover,
                  height: 90,
                  width: 65,
                  placeholderCacheHeight: 90,
                  placeholderCacheWidth: 65,
                  placeholder: "assets/404img.png",
                  image: _anime.picture.toString(),
                  imageErrorBuilder: (context, error, stackTrace) => SizedBox(
                    height: 90,
                    width: 65,
                    child: Image.asset("assets/404img.png"),
                  ),
                ),
              ),
              SizedBox(
                width: size.width - 85,
                child: Column(
                  children: [
                    Text(
                      _anime.title,
                      style: const TextStyle(color: Colors.white, fontSize: 20.0),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _animeDetails,
                      initialData: const {"mean": "Loading data."},
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        Text text = const Text("");
                        if (snapshot.hasData) {
                          text = Text(
                            "Mean Score: ${snapshot.data["mean"]}",
                            style: const TextStyle(
                                color: Colors.amber, fontSize: 15.0),
                          );
                        } else if (snapshot.hasError) {
                          text = const Text(
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
                child: InkWell(
                  onTap: () => _showOverlay('status'),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.bar_chart, color: Colors.white),
                      Text(
                        _chosenListStatus,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showOverlay("episodes"),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.remove_red_eye, color: Colors.white),
                      Text(
                        "$_chosenEpsWatched/${_anime.totalEpisodes}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showOverlay("score"),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.star, color: Colors.white),
                      Text(
                        _chosenScore,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Display a button if a change was made to update list item
          _detailChanged
              ? TextButton(
                  onPressed: _updateItem,
                  child: const Text("Update List"),
                )
              : const SizedBox(height: 0, width: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _animeDetails,
              initialData: const {"loading": true},
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List<Widget> children = <Widget>[];
                if (snapshot.hasData) {
                  children = _buildInfoList(snapshot.data, size);
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    const Text("Error loading data. Please try again later."),
                  ];
                }
                return Column(children: children);
              },
            ),
          ),
        ],
      ),
    );
  }
}
