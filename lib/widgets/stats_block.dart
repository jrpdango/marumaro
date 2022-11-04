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
              Stat(
                statName: 'Ranked',
                count: anime?.rank,
              ),
              Stat(
                statName: 'Popularity',
                count: anime?.popularity,
              ),
              Stat(
                statName: 'Members:',
                count: anime?.numListUsers,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom widget for [StatsBlock].
///
class Stat extends StatelessWidget {
  final String statName;
  final int? count;

  const Stat({
    required this.statName,
    this.count,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text.rich(
        TextSpan(
          text: statName,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.normal,
              ),
          children: <TextSpan>[
            TextSpan(
              text: count != null ? ' #$count' : ' N/A',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
    );
  }
}
