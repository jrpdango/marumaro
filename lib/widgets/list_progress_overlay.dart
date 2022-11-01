import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/utils/progress_formatter.dart';
import 'package:miru/widgets/base_overlay.dart';
import 'package:miru/widgets/overlay_button.dart';

class ListProgressOverlay extends StatelessWidget {
  final Function onChanged;
  final int? currentProgress;
  final int? total;
  final TextEditingController _controller = TextEditingController();

  ListProgressOverlay({
    required this.onChanged,
    required this.currentProgress,
    required this.total,
    Key? key,
  }) : super(key: key);

  String? get formattedText {
    try {
      int parsedText = int.parse(_controller.text);
      if (total == null) return null;
      if (parsedText <= total! && parsedText >= 0) {
        return _controller.text;
      }
    } catch (_) {
      debugPrint(
        'Something went wrong with the int input. It\'s probably null.',
      );
    }
    return currentProgress?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BaseOverlay(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Set your progress',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                      hintText: currentProgress?.toString() ?? '',
                      counterText: '',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8.0, top: 16.0),
                  child: Text(
                    '/ ${ProgressFormatter.format(total)}',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 64.0,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: OverlayButton(
              onPressed: () {
                onChanged.call(formattedText);
              },
              topText: 'Confirm',
              // Marked as isSelected to make it a brighter blue
              isSelected: true,
            ),
          ),
        ],
      ),
    );
  }
}
