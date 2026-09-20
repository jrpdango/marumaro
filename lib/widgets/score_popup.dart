import 'package:flutter/material.dart';

class ScorePopup extends StatefulWidget {
  const ScorePopup({
    super.key,
    required this.closeOverlayCallback,
    required this.callback,
    required this.scoreChoice,
    required this.initialScore,
  });

  final Function closeOverlayCallback;
  final Function callback;
  final Function scoreChoice;
  final int initialScore;

  @override
  State<ScorePopup> createState() => _ScorePopupState();
}

class _ScorePopupState extends State<ScorePopup> {
  late int _currentScore = widget.initialScore;
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initialScore);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 180,
            width: 120,
            color: Colors.grey[850],
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) => _currentScore = index,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 11,
                builder: (context, index) => Center(
                  child: Text(
                    "$index",
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (widget.initialScore != _currentScore) widget.callback(true);
              widget.scoreChoice(_currentScore.toString());
              widget.closeOverlayCallback();
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
