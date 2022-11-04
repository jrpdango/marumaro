import 'package:flutter/material.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/widgets/mean_score_users.dart';

class StatsBlock extends StatelessWidget {
  final Anime? anime;
  const StatsBlock({
    this.anime,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: MeanScoreUsers(
            meanScore: anime?.meanScore,
            users: anime?.numScoringUsers,
          ),
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
