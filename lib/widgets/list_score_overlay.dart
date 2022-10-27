import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:miru/widgets/base_overlay.dart';

class ListScoreOverlay extends StatelessWidget {
  const ListScoreOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextButton(
            onPressed: () {},
            child: Column(
              children: const <Text>[
                Text('0'),
                Text('Unrated'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
