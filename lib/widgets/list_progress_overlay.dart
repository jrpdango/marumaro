import 'package:flutter/material.dart';
import 'package:miru/widgets/base_overlay.dart';

class ListProgressOverlay extends StatefulWidget {
  const ListProgressOverlay({Key? key}) : super(key: key);

  @override
  State<ListProgressOverlay> createState() => _ListProgressOverlayState();
}

class _ListProgressOverlayState extends State<ListProgressOverlay> {
  @override
  Widget build(BuildContext context) {
    return BaseOverlay(
      child: Column(
        children: const <Widget>[
          Text('Test Overlay'),
          TextField(
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
