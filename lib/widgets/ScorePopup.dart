import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class ScorePopup extends StatefulWidget {
  final OverlayEntry overlayEntry;
  final Function callback;
  final Function scoreChoice;

  const ScorePopup({this.overlayEntry, this.callback, this.scoreChoice});
  @override
  _ScorePopupState createState() => _ScorePopupState();
}

class _ScorePopupState extends State<ScorePopup> {
  List<Column> buildScores() {
    List<Column> scoreList = [];

    for (int i = 0; i < 10; i++) {
      scoreList.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              i.toString(),
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Text(
              "Nice",
              style: TextStyle(fontSize: 40),
            ),
          ],
        ),
      );
    }
    return scoreList;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    int score = 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size.height / 6,
            width: size.width / 1.3,
            color: Colors.grey[850],
            child: InfiniteCarousel.builder(
              loop: false,
              velocityFactor: 0.4,
              itemCount: 11,
              itemExtent: size.width / 1.5,
              onIndexChanged: (index) {
                score = index;
              },
              itemBuilder: (context, itemIndex, realIndex) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      itemIndex.toString(),
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      "Nice",
                      style: TextStyle(fontSize: 40),
                    ),
                  ],
                );
              },
            ),
          ),
          TextButton(
            onPressed: () {
              // print(score);
              widget.callback(true);
              widget.scoreChoice(score.toString());
              widget.overlayEntry.remove();
            },
            child: Text("Done"),
          )
        ],
      ),
    );
  }
}
