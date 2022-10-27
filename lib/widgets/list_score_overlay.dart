import 'package:flutter/material.dart';
import 'package:miru/widgets/base_overlay.dart';

class ListScoreOverlay extends StatelessWidget {
  const ListScoreOverlay({Key? key}) : super(key: key);

  List<Row> get _buttonRows {
    List<String> buttonTexts = [
      'Apalling',
      'Horrible',
      'Very Bad',
      'Bad',
      'Average',
      'Fine',
      'Good',
      'Very Good',
      'Great',
      'Masterpiece',
    ];

    List<Row> rows = [];
    for (int i = 0; i < buttonTexts.length; i += 2) {
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Expanded>[
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: Column(
                  children: <Widget>[
                    Text('${i + 1}'),
                    Text(buttonTexts[i]),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: Column(
                  children: <Widget>[
                    Text('${i + 2}'),
                    Text(buttonTexts[i + 1]),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return BaseOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextButton(
            onPressed: () {},
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: const <Text>[
                  Text('0'),
                  Text('Unrated'),
                ],
              ),
            ),
          ),
          Column(
            children: _buttonRows,
          ),
        ],
      ),
    );
  }
}
