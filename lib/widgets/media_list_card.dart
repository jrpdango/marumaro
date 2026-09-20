import 'package:flutter/material.dart';
import 'package:miru/widgets/anime_poster.dart';
import 'package:miru/widgets/show_details.dart';

/// A tappable list card showing a poster and its details.
class MediaListCard extends StatelessWidget {
  const MediaListCard({
    super.key,
    required this.picture,
    required this.title,
    required this.progress,
    required this.score,
    required this.statusLabel,
    required this.onTap,
    this.statusPrefix = "Show Status",
  });

  final Uri picture;
  final String title;
  final String progress;
  final String score;
  final String statusLabel;
  final VoidCallback onTap;
  final String statusPrefix;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
              ),
              child: AnimePoster(picture: picture),
            ),
            Expanded(
              child: ShowDetails(
                title: title,
                progress: progress,
                score: score,
                airingStatus: statusLabel,
                statusPrefix: statusPrefix,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
