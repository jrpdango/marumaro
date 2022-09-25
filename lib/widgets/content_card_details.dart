import 'package:flutter/material.dart';

class ContentCardDetails extends StatelessWidget {
  // TODO: Add more properties and format within this widget
  final String title;
  final String progress;
  // TODO: Make this an int
  final String score;
  final String airingStatus;

  const ContentCardDetails({
    Key? key,
    required this.title,
    required this.progress,
    required this.score,
    required this.airingStatus,
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
      // color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                Text(
                  _makeConciseTitle(title),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 25.0),
            child: Row(
              children: [
                const SizedBox(height: 5.0),
                Text(
                  'Show Status: ${_makeCleanStatus(airingStatus)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Text(
                  'Progress: $progress',
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
                        score,
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
