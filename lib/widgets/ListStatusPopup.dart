import 'package:flutter/material.dart';

class ListStatusPopup extends StatefulWidget {
  final OverlayEntry overlayEntry;
  final Function callback;
  final Function stringChoice;

  const ListStatusPopup({this.overlayEntry, this.callback, this.stringChoice});
  @override
  _ListStatusPopupState createState() => _ListStatusPopupState();
}

class _ListStatusPopupState extends State<ListStatusPopup> {
  List<Widget> buildStatusList() {
    List<String> listStatus = [
      "Watching",
      "Plan to Watch",
      "Completed",
      "On Hold",
      "Dropped"
    ];
    List<Widget> optionList = [];
    for (String element in listStatus) {
      optionList.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 40.0),
        child: TextButton(
            onPressed: () {
              widget.callback(true);
              widget.stringChoice(element);
              widget.overlayEntry.remove();
            },
            child: Text(element)),
      ));
    }
    return optionList;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[850],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: this.buildStatusList(),
        ),
      ),
    );
  }
}
