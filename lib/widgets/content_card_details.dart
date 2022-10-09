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
      padding: const EdgeInsets.fromLTRB(
        10.0,
        2.0,
        2.0,
        2.0,
      ),
      height: 140.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Show Status: ${_makeCleanStatus(airingStatus)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Progress: $episodesWatched/$totalEpisodes',
                    style: Theme.of(context).textTheme.bodyMedium,
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
              )
            ],
          ),
        ],
      ),
    );
  }
}
