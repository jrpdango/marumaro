import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A popup for editing a progress count (episodes watched, chapters read, ...).
class MediaProgressPopup extends StatefulWidget {
  final Function closeOverlayCallback;
  final Function callback;
  final Function progressChoice;
  final int total;
  final int initialProgress;
  final String label;

  const MediaProgressPopup(
      {super.key,
      required this.closeOverlayCallback,
      required this.callback,
      required this.progressChoice,
      required this.total,
      required this.initialProgress,
      required this.label});

  @override
  State<MediaProgressPopup> createState() => _MediaProgressPopupState();
}

class _MediaProgressPopupState extends State<MediaProgressPopup> {
  final TextEditingController _controller = TextEditingController();
  bool progressChanged = false;
  String currentProgress = "";

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialProgress.toString();
  }

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
              "${widget.label}: ${widget.total}",
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
                  final int? parsed = int.tryParse(value);
                  final bool isValid = parsed != null &&
                      (widget.total == 0 || parsed <= widget.total);
                  if (!isValid) {
                    setState(() {
                      progressChanged = false;
                    });
                    if (value.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("The maximum is ${widget.total}."),
                        ),
                      );
                    }
                    return;
                  }
                  setState(() {
                    progressChanged = parsed != widget.initialProgress;
                  });
                  currentProgress = value;
                },
              ),
            ),
            progressChanged
                ? TextButton(
                    onPressed: () {
                      widget.callback(true);
                      widget.progressChoice(currentProgress);
                      widget.closeOverlayCallback();
                    },
                    child: Text("Done"),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  )
          ],
        ),
      ),
    );
  }
}
