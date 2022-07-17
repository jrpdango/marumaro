import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListStatusPopup extends StatefulWidget {
  final Rx<String> statusChoice;
  final Function detailChangedCallback;
  final Function closeOverlayCallback;

  const ListStatusPopup(
      {required this.statusChoice,
      required this.detailChangedCallback,
      required this.closeOverlayCallback});
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
      optionList.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 40.0),
          child: TextButton(
            onPressed: () {
              if (element != widget.statusChoice.value)
                widget.detailChangedCallback(true);
              widget.statusChoice.value = element;
              widget.closeOverlayCallback();
            },
            child: Text(element),
          ),
        ),
      );
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
