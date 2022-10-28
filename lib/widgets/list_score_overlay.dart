import 'package:flutter/material.dart';
import 'package:miru/constants.dart';
import 'package:miru/widgets/base_overlay.dart';
import 'package:miru/widgets/overlay_button.dart';

class ListScoreOverlay extends StatelessWidget {
  final int currentScore;

  const ListScoreOverlay({
    Key? key,
    required this.currentScore,
  }) : super(key: key);

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
              isSelected: (i + 1) == currentScore,
            ),
            ButtonCell(
              topText: (i + 2).toString(),
              bottomText: buttonTexts[i + 1],
              isSelected: (i + 2) == currentScore,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {},
                style: currentScore == 0
                    ? TextButton.styleFrom(
                        backgroundColor: MiruColors.buttonColor,
                      )
                    : TextButton.styleFrom(
                        backgroundColor: MiruColors.unselectedButtonColor,
                      ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '0',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: MiruColors.textColor,
                          ),
                    ),
                    Text(
                      'Unrated',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: MiruColors.textColor,
                          ),
                    ),
                  ],
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

/// Custom [Widget] for [ListScoreOverlay]. This is intended to be used within
/// a function that produces a [Column] with [Row] children that contain
/// two [ButtonCell] each.
///
class ButtonCell extends StatelessWidget {
  final String topText;
  final String bottomText;
  final EdgeInsetsGeometry padding;
  final bool isSelected;

  const ButtonCell({
    this.topText = '',
    this.bottomText = '',
    this.padding = const EdgeInsets.all(8.0),
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: padding,
        child: OverlayButton(
          onPressed: () {},
          topText: topText,
          bottomText: bottomText,
          hasColumn: true,
          isSelected: isSelected,
        ),
      ),
    );
  }
}
