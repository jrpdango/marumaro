import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EpisodesWatchedPopup extends StatefulWidget {
  final Function closeOverlayCallback;
  final Function callback;
  final Function numEpsChoice;
  final int totalEps;

  const EpisodesWatchedPopup(
      {Key key,
      this.closeOverlayCallback,
      this.callback,
      this.numEpsChoice,
      this.totalEps})
      : super(key: key);

  @override
  _EpisodesWatchedPopupState createState() => _EpisodesWatchedPopupState();
}

class _EpisodesWatchedPopupState extends State<EpisodesWatchedPopup> {
  final TextEditingController _controller = TextEditingController();
  bool epsChanged = false;
  String currentEps = "";

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
                  if (value != widget.totalEps.toString() && value != "") {
                    setState(() {
                      epsChanged = true;
                    });
                    currentEps = value;
                  } else {
                    setState(() {
                      epsChanged = false;
                    });
                    return;
                  }
                },
              ),
            ),
            epsChanged
                ? TextButton(
                    onPressed: () {
                      widget.callback(true);
                      widget.numEpsChoice(currentEps);
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
