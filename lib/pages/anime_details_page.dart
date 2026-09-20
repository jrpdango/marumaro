import 'package:flutter/material.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/anime_details.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/anime_poster.dart';
import 'package:miru/widgets/episodes_watched_popup.dart';
import 'package:miru/widgets/list_status_popup.dart';
import 'package:miru/widgets/loading_popup.dart';
import 'package:miru/widgets/score_popup.dart';

class AnimeDetailsPage extends StatefulWidget {
  const AnimeDetailsPage({super.key, required this.anime});

  final Anime anime;

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  GlobalController? _controller;

  bool _detailChanged = false;
  late AnimeListStatus _chosenStatus = widget.anime.userStatus;
  late int _chosenScore = widget.anime.userScore;
  late int _chosenEpsWatched = widget.anime.userEpisodesWatched;
  Future<AnimeDetails>? _animeDetails;

  Anime get _anime => widget.anime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    _animeDetails ??=
        _controller!.repository.fetchAnimeDetails(widget.anime.id);
  }

  /// Sends the pending changes to MAL and updates local state.
  Future<void> _updateItem() async {
    _showOverlay("loading");
    try {
      await _controller!.updateAnime(
        anime: _anime,
        status: _chosenStatus,
        score: _chosenScore,
        episodesWatched: _chosenEpsWatched,
      );
      if (mounted) setState(() => _detailChanged = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update list.")),
        );
      }
    } finally {
      // Dismiss the loading overlay.
      if (mounted) Navigator.of(context).pop();
    }
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
            stringChoice: (choice) => setState(
              () => _chosenStatus = AnimeListStatus.fromApiValue(
                choice.replaceAll(" ", "_").toLowerCase(),
              ),
            ),
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
            numEpsChoice: (choice) =>
                setState(() => _chosenEpsWatched = int.parse(choice)),
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
            scoreChoice: (choice) =>
                setState(() => _chosenScore = int.parse(choice)),
            initialScore: _chosenScore,
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

  /// Creates the rows displayed for [details].
  List<Widget> _buildInfoList(AnimeDetails details) {
    return details.displayRows.map((MapEntry<String, String> row) {
      return SizedBox(
        height: 20.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  row.key,
                  style: const TextStyle(color: Colors.white, fontSize: 10.0),
                ),
              ),
              Expanded(
                child: Text(
                  row.value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 10.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                child: AnimePoster(picture: _anime.picture),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _anime.title,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20.0),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FutureBuilder<AnimeDetails>(
                      future: _animeDetails,
                      builder: (BuildContext context,
                          AsyncSnapshot<AnimeDetails> snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            "Mean Score: ${snapshot.data!.meanScore}",
                            style: const TextStyle(
                                color: Colors.amber, fontSize: 15.0),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                              "Error loading data. Please try again later.");
                        }
                        return const Text("");
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
                        _chosenStatus.label,
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
                        "$_chosenScore",
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
            child: FutureBuilder<AnimeDetails>(
              future: _animeDetails,
              builder:
                  (BuildContext context, AsyncSnapshot<AnimeDetails> snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error loading data. Please try again later.");
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.amber),
                    ),
                  );
                }
                return Column(
                  children: _buildInfoList(snapshot.data!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
