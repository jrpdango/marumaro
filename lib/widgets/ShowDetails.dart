import 'package:flutter/material.dart';

class ShowDetails extends StatefulWidget {
  final String title;
  final String progress;
  final String score;
  final String airingStatus;

  const ShowDetails(
      {Key key, this.title, this.progress, this.score, this.airingStatus})
      : super(key: key);

  @override
  _ShowDetailsState createState() => _ShowDetailsState();
}

class _ShowDetailsState extends State<ShowDetails> {
  @override
  void initState() {
    super.initState();
  }

  String conciseTitle(String fullTitle) {
    if (fullTitle.length >= 24) {
      return fullTitle.substring(0, 24) + "...";
    }
    return fullTitle;
  }

  String cleanStatus(String rawStatus) {
    if (rawStatus == "finished_airing") {
      return "Finished Airing";
    } else if (rawStatus == "currently_airing") {
      return "Currently Airing";
    }
    return rawStatus;
  }

  Widget build(BuildContext context) => Container(
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
                    "  ${conciseTitle(widget.title)}",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 25.0),
              child: Row(
                children: [
                  SizedBox(height: 5.0),
                  Text("   Show Status: ${cleanStatus(widget.airingStatus)}",
                      style: TextStyle(color: Colors.white, fontSize: 13.0)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Text(
                    "   Progress: ${widget.progress}",
                    style: TextStyle(color: Colors.white, fontSize: 13.0),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text(""),
                      ],
                    ),
                  ),
                  Card(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 6.0,
                        ),
                        Text(
                          "${widget.score}",
                          style:
                              TextStyle(color: Colors.black87, fontSize: 13.0),
                        ),
                        Icon(Icons.star, size: 13.0),
                        SizedBox(
                          width: 5.0,
                        )
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
