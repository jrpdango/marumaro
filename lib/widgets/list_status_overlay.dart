import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:miru/constants.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/models/anime.dart';

class ListStatusOverlay extends StatelessWidget {
  final AnimeListType? animeListType;
  final Function? callback;
  const ListStatusOverlay({
    this.animeListType,
    this.callback,
    Key? key,
  }) : super(key: key);

  List<Widget> _buildStatusList(BuildContext context) {
    List<Widget> statusList = [];
    List<AnimeListType> statuses = [
      AnimeListType.watching,
      AnimeListType.planToWatch,
      AnimeListType.completed,
      AnimeListType.onHold,
      AnimeListType.dropped,
    ];
    for (AnimeListType status in statuses) {
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
            onPressed: () {
              if (callback != null) {
                callback!.call(status);
              }
              debugPrint(status.apiName);
            },
            style: TextButton.styleFrom(
              backgroundColor: MiruColors.buttonColor,
            ),
            child: Text(
              status.displayName,
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
