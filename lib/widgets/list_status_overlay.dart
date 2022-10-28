import 'package:flutter/material.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/widgets/base_overlay.dart';
import 'package:miru/widgets/overlay_button.dart';

class ListStatusOverlay extends StatelessWidget {
  final AnimeListType? currentStatus;
  final Function? onSelect;
  const ListStatusOverlay({
    this.currentStatus,
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
          child: OverlayButton(
            onPressed: () {
              if (onSelect != null) {
                onSelect!.call(status);
              }
            },
            topText: status.displayName,
            isSelected: currentStatus == status,
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
