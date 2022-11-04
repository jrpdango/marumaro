import 'package:flutter/material.dart';
import 'package:miru/constants.dart';

class MeanScoreUsers extends StatelessWidget {
  final double? meanScore;
  final int? users;

  const MeanScoreUsers({
    this.meanScore,
    this.users,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 8.0,
      ),
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 4.0),
              decoration: const BoxDecoration(
                color: MiruColors.primaryVariant,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Mean Score',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(fontSize: 14.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                meanScore?.toString() ?? '0.00',
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: MiruColors.textColor,
                    ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 2.0,
                bottom: 8.0,
              ),
              child: Text('${users ?? 'No'} users'),
            ),
          ],
        ),
      ),
    );
  }
}
