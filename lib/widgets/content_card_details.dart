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

  Color _getScoreColor() {
    switch (score) {
      case 1:
      case 2:
      case 3:
        return Colors.red;
      case 4:
      case 5:
      case 6:
        return Colors.amber.shade700;
      case 7:
      case 8:
      case 9:
        return Colors.green;
      case 10:
        return const Color(0xFF21E9FF);
      default:
        return Colors.white;
    }
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
          Padding(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Progress: $episodesWatched/$totalEpisodes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                  ),
                ),
                Card(
                  color: _getScoreColor(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 5.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          score.toString(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13.0,
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.black87,
                          size: 13.0,
                        ),
                      ],
                    ),
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
