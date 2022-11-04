import 'package:flutter/material.dart';
import 'package:miru/widgets/mean_score_users.dart';

class StatsBlock extends StatelessWidget {
  const StatsBlock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          flex: 2,
          child: MeanScoreUsers(),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: <Widget>[
              Text('asdf'),
              Text('asdf2'),
            ],
          ),
        ),
      ],
    );
  }
}
