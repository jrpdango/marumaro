import 'package:flutter/material.dart';
import 'package:miru/constants.dart';

/// Styled [TextButton] intended for use in custom [Dialog].
///
class OverlayButton extends StatelessWidget {
  final Function onPressed;
  final String topText;
  final String? bottomText;
  final bool isSelected;
  final bool hasColumn;

  /// Styled [TextButton] intended for use in custom [Dialog].
  ///
  /// The [topText] argument must not be null.
  /// [bottomText] is applied only when [hasColumn] is true.
  ///
  const OverlayButton({
    required this.onPressed,
    required this.topText,
    this.bottomText,
    this.isSelected = false,
    this.hasColumn = false,
    Key? key,
  }) : super(key: key);

  Widget _intendedChild(TextStyle? style) {
    if (!hasColumn) {
      return Text(
        topText,
        style: style,
      );
    } else {
      return Column(
        children: <Widget>[
          Text(
            topText,
            style: style,
          ),
          Text(
            bottomText ?? '',
            style: style,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onPressed.call();
      },
      style: isSelected
          ? TextButton.styleFrom(
              backgroundColor: MiruColors.buttonColor,
            )
          : TextButton.styleFrom(
              backgroundColor: MiruColors.unselectedButtonColor,
            ),
      child: _intendedChild(
        Theme.of(context).textTheme.bodyText1?.copyWith(
              color: MiruColors.textColor,
            ),
      ),
    );
  }
}
