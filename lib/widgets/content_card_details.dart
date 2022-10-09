import 'package:flutter/material.dart';
import 'package:miru/constants.dart' show MiruColors;

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

  String _makeCleanStatus(String rawStatus) {
    if (rawStatus == 'finished_airing') {
      return 'Finished Airing';
    } else if (rawStatus == 'currently_airing') {
      return 'Currently Airing';
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
        return MiruColors.primaryColor;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      height: 140.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // TODO: Long text with <= 24 can still overflow
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
            overflow: TextOverflow.ellipsis,
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
                    padding: const EdgeInsets.only(left: 7.0, right: 5.0),
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
