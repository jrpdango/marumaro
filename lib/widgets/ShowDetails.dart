import 'package:flutter/material.dart';

class ShowDetails extends StatefulWidget {
  final String title;
  final String progress;
  final String score;

  const ShowDetails({Key key, this.title, this.progress, this.score})
      : super(key: key);

  @override
  _ShowDetailsState createState() => _ShowDetailsState();
}

class _ShowDetailsState extends State<ShowDetails> {
  @override
  void initState() {
    super.initState();
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
                    "  ${widget.title}",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text(""),
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
                  Text(
                    widget.score,
                    style: TextStyle(color: Colors.white, fontSize: 10.0),
                  ),
                ],
              ),
            )
          ],
        ),
      );
}
