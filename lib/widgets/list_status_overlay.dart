import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:miru/constants.dart';
import 'package:miru/models/anime.dart';

class ListStatusOverlay extends StatelessWidget {
  final Rx<Anime>? anime;
  const ListStatusOverlay({
    this.anime,
    Key? key,
  }) : super(key: key);

  List<Widget> _buildStatusList(BuildContext context) {
    List<Widget> statusList = [];
    List<String> statuses = [
      'Watching',
      'Plan to Watch',
      'Completed',
      'On Hold',
      'Dropped'
    ];
    for (String status in statuses) {
      statusList.add(
        Container(
          height: 64.0,
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 320.0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: MiruColors.buttonColor,
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: MiruColors.textColor,
                  ),
            ),
          ),
        ),
      );
    }
    return statusList;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: double.infinity,
        constraints: const BoxConstraints(maxHeight: 360.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: MiruColors.cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildStatusList(context),
        ),
      ),
    );
  }
}
