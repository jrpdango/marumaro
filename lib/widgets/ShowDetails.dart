import 'package:flutter/material.dart';

class ShowDetails extends StatefulWidget {
  final String title;
  final String status;
  final String progress;
  final String score;

  const ShowDetails(
      {Key key, this.title, this.status, this.progress, this.score})
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
        child: Column(
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Text(
              widget.status,
              style: TextStyle(color: Colors.white, fontSize: 10.0),
            ),
            Row(
              children: <Widget>[
                Text(
                  "Progress: ${widget.progress}",
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  widget.score,
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                ),
              ],
            )
          ],
        ),
      );
}
