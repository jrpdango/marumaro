import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EpisodesWatchedPopup extends StatefulWidget {
  final Function closeOverlayCallback;
  final Function callback;
  final Rx<int> numEpsChoice;
  final int totalEps;

  const EpisodesWatchedPopup(
      {Key? key,
      required this.closeOverlayCallback,
      required this.callback,
      required this.numEpsChoice,
      required this.totalEps})
      : super(key: key);

  @override
  _EpisodesWatchedPopupState createState() => _EpisodesWatchedPopupState();
}

class _EpisodesWatchedPopupState extends State<EpisodesWatchedPopup> {
  final TextEditingController _controller = TextEditingController();
  int _currentEps = 0;
  bool _isValidEpisodeCount = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[850],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Total Episodes: ${widget.totalEps}",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Card(
              child: TextField(
                controller: _controller,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  if (value == "") value = "${widget.numEpsChoice.value}";
                  if ((int.parse(value) <= widget.totalEps ||
                      widget.totalEps == 0)) {
                    _isValidEpisodeCount = true;
                    _currentEps = int.parse(value);
                  } else {
                    _isValidEpisodeCount = false;
                  }
                },
              ),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text == "")
                  _currentEps = widget.numEpsChoice.value;
                if (_isValidEpisodeCount ||
                    _currentEps == widget.numEpsChoice.value) {
                  if (_currentEps != widget.numEpsChoice.value) {
                    widget.callback(true);
                    widget.numEpsChoice.value = _currentEps;
                  }
                  widget.closeOverlayCallback();
                  SystemChrome.restoreSystemUIOverlays();
                } else if (widget.totalEps > 0) {
                  Get.snackbar(
                    "Uh oh!",
                    "This show only has ${widget.totalEps} episodes.",
                    snackPosition: SnackPosition.BOTTOM,
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                }
              },
              child: Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
