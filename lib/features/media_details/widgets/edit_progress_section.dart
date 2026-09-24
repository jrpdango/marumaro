part of '../edit_list_page.dart';

/// The progress section: episodes/chapters, plus volumes for manga.
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.labels,
    required this.progress,
    required this.progressTotal,
    required this.volumes,
    required this.volumeTotal,
  });

  final MediaKindLabels labels;
  final TextEditingController progress;
  final int? progressTotal;
  final TextEditingController volumes;
  final int? volumeTotal;

  @override
  Widget build(BuildContext context) {
    return _EditSection(
      title: "Progress",
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(labels.progressField)),
              SizedBox(
                width: 120.0,
                child: NumberField(controller: progress, total: progressTotal),
              ),
            ],
          ),
          if (!labels.isAnime) ...<Widget>[
            const SizedBox(height: AppTokens.spaceSm),
            Row(
              children: <Widget>[
                Expanded(child: Text(labels.volumesField)),
                SizedBox(
                  width: 120.0,
                  child: NumberField(controller: volumes, total: volumeTotal),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
