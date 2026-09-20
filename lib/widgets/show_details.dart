import 'package:flutter/material.dart';

/// The title, status, progress, and score shown on a list card.
class ShowDetails extends StatelessWidget {
  const ShowDetails({
    super.key,
    required this.title,
    required this.progress,
    required this.score,
    required this.airingStatus,
    this.statusPrefix = "Show Status",
  });

  final String title;
  final String progress;
  final String score;
  final String airingStatus;
  final String statusPrefix;

  String _conciseTitle(String fullTitle) {
    if (fullTitle.length >= 24) {
      return "${fullTitle.substring(0, 24)}...";
    }
    return fullTitle;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _conciseTitle(title),
              style: const TextStyle(color: Colors.white, fontSize: 20.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "$statusPrefix: $airingStatus",
              style: const TextStyle(color: Colors.white, fontSize: 13.0),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Progress: $progress",
                    style: const TextStyle(color: Colors.white, fontSize: 13.0),
                  ),
                ),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 1.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          score,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 13.0),
                        ),
                        const Icon(Icons.star, size: 13.0, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
