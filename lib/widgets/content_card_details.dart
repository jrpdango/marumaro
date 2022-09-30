import 'package:flutter/material.dart';

class ContentCardDetails extends StatelessWidget {
  final String title;
  final String airingStatus;
  final int score;
  final int episodesWatched;
  final int totalEpisodes;

  const ContentCardDetails({
    Key? key,
    required this.title,
    required this.airingStatus,
    required this.score,
    required this.episodesWatched,
    required this.totalEpisodes,
  }) : super(key: key);

  String _makeConciseTitle(String fullTitle) {
    if (fullTitle.length >= 24) {
      return '${fullTitle.substring(0, 24)}...';
    }
    return fullTitle;
  }

  String _makeCleanStatus(String rawStatus) {
    if (rawStatus == "finished_airing") {
      return "Finished Airing";
    } else if (rawStatus == "currently_airing") {
      return "Currently Airing";
    }
    return rawStatus;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: This hasn't been cleaned up, just copied from old miru
    return SizedBox(
      width: 267.0,
      height: 90.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Text(
              _makeConciseTitle(title),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 25.0),
            child: Text(
              'Show Status: ${_makeCleanStatus(airingStatus)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.0,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Text(
                  'Progress: $episodesWatched/$totalEpisodes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: const <Widget>[
                      Text(''),
                    ],
                  ),
                ),
                Card(
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 6.0,
                      ),
                      Text(
                        score.toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13.0,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        size: 13.0,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
