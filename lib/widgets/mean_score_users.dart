import 'package:flutter/material.dart';
import 'package:miru/constants.dart';

class MeanScoreUsers extends StatelessWidget {
  const MeanScoreUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: MiruColors.primaryVariant,
            child: Text(
              'Mean Score',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ),
          Text('1.23'),
          Text('1234567890 users'),
        ],
      ),
    );
  }
}
