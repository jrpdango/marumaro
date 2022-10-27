import 'package:flutter/material.dart';
import 'package:miru/constants.dart';
import 'package:miru/widgets/base_overlay.dart';

class ListScoreOverlay extends StatelessWidget {
  const ListScoreOverlay({Key? key}) : super(key: key);

  List<Row> _buttonRows(BuildContext context) {
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
          children: <ButtonCell>[
            ButtonCell(
              topText: (i + 1).toString(),
              bottomText: buttonTexts[i],
            ),
            ButtonCell(
              topText: (i + 2).toString(),
              bottomText: buttonTexts[i + 1],
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: 8.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              child: const SizedBox(
                width: double.infinity,
                child: ButtonCell(
                  topText: '0',
                  bottomText: 'Unrated',
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            Column(
              children: _buttonRows(context),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonCell extends StatelessWidget {
  final String topText;
  final String bottomText;
  final EdgeInsetsGeometry padding;

  const ButtonCell({
    this.topText = '',
    this.bottomText = '',
    this.padding = const EdgeInsets.all(8.0),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: padding,
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            backgroundColor: MiruColors.unselectedButtonColor,
          ),
          child: Column(
            children: <Widget>[
              Text(
                topText,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: MiruColors.textColor,
                    ),
              ),
              Text(
                bottomText,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: MiruColors.textColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
