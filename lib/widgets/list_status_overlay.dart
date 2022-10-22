import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:miru/constants.dart';
import 'package:miru/models/anime.dart';

class ListStatusOverlay extends StatelessWidget {
  final Rx<Anime>? anime;
  const ListStatusOverlay({
    this.anime,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: MiruColors.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Text('hello'),
            Text('hello'),
            Text('hello'),
          ],
        ),
      ),
    );
  }
}
