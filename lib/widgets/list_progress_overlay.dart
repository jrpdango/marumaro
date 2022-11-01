import 'package:flutter/material.dart';
import 'package:miru/utils/progress_formatter.dart';
import 'package:miru/widgets/base_overlay.dart';

class ListProgressOverlay extends StatelessWidget {
  final Function onChanged;
  final int? currentProgress;
  final int? total;

  const ListProgressOverlay({
    required this.onChanged,
    required this.currentProgress,
    required this.total,
    Key? key,
  }) : super(key: key);

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
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                      hintText: currentProgress?.toString() ?? '',
                    ),
                    keyboardType: TextInputType.number,
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
        ],
      ),
    );
  }
}
