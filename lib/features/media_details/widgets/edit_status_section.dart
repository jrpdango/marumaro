part of '../edit_list_page.dart';

/// The status section: one choice chip per list status.
class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<MapEntry<String, String>> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _EditSection(
      title: "Status",
      child: Wrap(
        spacing: AppTokens.spaceSm,
        runSpacing: AppTokens.spaceSm,
        children: options
            .map(
              (MapEntry<String, String> option) => ChoiceChip(
                label: Text(option.value),
                selected: selected == option.key,
                onSelected: (_) => onSelected(option.key),
              ),
            )
            .toList(),
      ),
    );
  }
}
