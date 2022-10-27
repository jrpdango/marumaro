import 'package:flutter/material.dart';
import 'package:miru/widgets/base_overlay.dart';

class ListProgressOverlay extends StatelessWidget {
  final int? currentProgress;
  final String? total;

  const ListProgressOverlay({
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
          Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: currentProgress?.toString() ?? '',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8.0, top: 16.0),
                    child: Text(
                      '/ $total',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
