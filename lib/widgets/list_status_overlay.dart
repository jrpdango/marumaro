import 'package:flutter/material.dart';
import 'package:miru/constants.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/widgets/base_overlay.dart';

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
            style: animeListType == status
                ? TextButton.styleFrom(
                    backgroundColor: MiruColors.buttonColor,
                  )
                : TextButton.styleFrom(
                    backgroundColor: MiruColors.unselectedButtonColor,
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
    return BaseOverlay(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: _buildStatusList(context),
      ),
    );
  }
}
