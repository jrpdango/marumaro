import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class ScorePopup extends StatefulWidget {
  final Function closeOverlayCallback;
  final Function detailChangedCallback;
  final Rx<int> scoreChoice;

  const ScorePopup(
      {required this.closeOverlayCallback,
      required this.detailChangedCallback,
      required this.scoreChoice});
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
    ScrollController _controller =
        InfiniteScrollController(initialItem: widget.scoreChoice.value);
    Size _size = MediaQuery.of(context).size;
    int _currentScore = widget.scoreChoice.value;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: _size.height / 6,
            width: _size.width / 1.3,
            color: Colors.grey[850],
            child: InfiniteCarousel.builder(
              controller: _controller,
              loop: false,
              velocityFactor: 0.4,
              itemCount: 11,
              itemExtent: _size.width / 1.5,
              onIndexChanged: (index) {
                _currentScore = index;
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
              if (widget.scoreChoice.value != _currentScore)
                widget.detailChangedCallback(true);
              widget.scoreChoice.value = _currentScore;
              widget.closeOverlayCallback();
            },
            child: Text("Done"),
          )
        ],
      ),
    );
  }
}
