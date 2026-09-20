import 'package:flutter/material.dart';

class ListStatusPopup extends StatefulWidget {
  final Function callback;
  final Function stringChoice;
  final Function closeOverlayCallback;
  final List<String> options;

  const ListStatusPopup(
      {super.key, required this.callback,
      required this.stringChoice,
      required this.options,
      required this.closeOverlayCallback});
  @override
  State<ListStatusPopup> createState() => _ListStatusPopupState();
}

class _ListStatusPopupState extends State<ListStatusPopup> {
  List<Widget> buildStatusList() {
    List<String> listStatus = widget.options;
    List<Widget> optionList = [];
    for (String element in listStatus) {
      optionList.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 40.0),
        child: TextButton(
            onPressed: () {
              widget.callback(true);
              widget.stringChoice(element);
              widget.closeOverlayCallback();
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
          children: buildStatusList(),
        ),
      ),
    );
  }
}
