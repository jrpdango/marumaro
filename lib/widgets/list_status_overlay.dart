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
        TextButton(
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
      );
    }
    return statusList;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: MiruColors.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildStatusList(context),
        ),
      ),
    );
  }
}
