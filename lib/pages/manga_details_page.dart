import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/models/manga_details.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/anime_poster.dart';
import 'package:miru/widgets/list_status_popup.dart';
import 'package:miru/widgets/loading_popup.dart';
import 'package:miru/widgets/media_progress_popup.dart';
import 'package:miru/widgets/score_popup.dart';

class MangaDetailsPage extends StatefulWidget {
  const MangaDetailsPage({super.key, required this.manga});

  final Manga manga;

  @override
  State<MangaDetailsPage> createState() => _MangaDetailsPageState();
}

class _MangaDetailsPageState extends State<MangaDetailsPage> {
  GlobalController? _controller;

  bool _detailChanged = false;
  late MangaListStatus _chosenStatus = widget.manga.userStatus;
  late int _chosenScore = widget.manga.userScore;
  late int _chosenChaptersRead = widget.manga.userChaptersRead;
  late int _chosenVolumesRead = widget.manga.userVolumesRead;
  Future<MangaDetails>? _mangaDetails;

  Manga get _manga => widget.manga;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    _mangaDetails ??=
        _controller!.repository.fetchMangaDetails(widget.manga.id);
  }

  /// Sends the pending changes to MAL and updates local state.
  Future<void> _updateItem() async {
    _showOverlay("loading");
    try {
      await _controller!.updateManga(
        manga: _manga,
        status: _chosenStatus,
        score: _chosenScore,
        chaptersRead: _chosenChaptersRead,
        volumesRead: _chosenVolumesRead,
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
            options: MangaListStatus.values
                .map((MangaListStatus status) => status.label)
                .toList(),
            stringChoice: (choice) => setState(
              () => _chosenStatus = MangaListStatus.fromApiValue(
                choice.replaceAll(" ", "_").toLowerCase(),
              ),
            ),
            closeOverlayCallback: () => Navigator.of(context).pop(),
          ),
        );
        break;
      case 'chapters':
        showDialog(
          context: context,
          barrierColor: const Color.fromRGBO(38, 38, 38, 0.8),
          builder: (_) => MediaProgressPopup(
            callback: (val) => setState(() => _detailChanged = val),
            progressChoice: (choice) =>
                setState(() => _chosenChaptersRead = int.parse(choice)),
            total: _manga.totalChapters,
            label: "Total Chapters",
            closeOverlayCallback: () => Navigator.of(context).pop(),
          ),
        );
        break;
      case 'volumes':
        showDialog(
          context: context,
          barrierColor: const Color.fromRGBO(38, 38, 38, 0.8),
          builder: (_) => MediaProgressPopup(
            callback: (val) => setState(() => _detailChanged = val),
            progressChoice: (choice) =>
                setState(() => _chosenVolumesRead = int.parse(choice)),
            total: _manga.totalVolumes,
            label: "Total Volumes",
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
  List<Widget> _buildInfoList(MangaDetails details) {
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
                child: AnimePoster(picture: _manga.picture),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _manga.title,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20.0),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FutureBuilder<MangaDetails>(
                      future: _mangaDetails,
                      builder: (BuildContext context,
                          AsyncSnapshot<MangaDetails> snapshot) {
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showOverlay("chapters"),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.menu_book, color: Colors.white),
                      Text(
                        "$_chosenChaptersRead/${_manga.totalChapters}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showOverlay("volumes"),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.library_books, color: Colors.white),
                      Text(
                        "$_chosenVolumesRead/${_manga.totalVolumes}",
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
            child: FutureBuilder<MangaDetails>(
              future: _mangaDetails,
              builder:
                  (BuildContext context, AsyncSnapshot<MangaDetails> snapshot) {
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
