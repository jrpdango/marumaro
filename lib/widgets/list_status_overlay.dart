import 'package:flutter/material.dart';
import 'package:miru/constants.dart';
import 'package:miru/enums/anime_list_type.dart';

class ListStatusOverlay extends StatelessWidget {
  final AnimeListType? animeListType;
  final Function? onSelect;
  const ListStatusOverlay({
    this.animeListType,
    this.onSelect,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: TextButton(
            onPressed: () {
              if (onSelect != null) {
                onSelect!.call(status);
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: MiruColors.cardColor,
        ),
        constraints: const BoxConstraints(
          maxWidth: 320.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _buildStatusList(context),
        ),
      ),
    );
  }
}
