part of '../edit_list_page.dart';

/// The organization section: priority and tags.
class _OrganizationSection extends StatelessWidget {
  const _OrganizationSection({
    required this.priority,
    required this.onPriorityChanged,
    required this.tags,
  });

  final int priority;
  final ValueChanged<int> onPriorityChanged;
  final TextEditingController tags;

  @override
  Widget build(BuildContext context) {
    return _EditSection(
      title: "Organization",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text("Priority"),
          const SizedBox(height: AppTokens.spaceSm),
          SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 0, label: Text("Low")),
              ButtonSegment<int>(value: 1, label: Text("Medium")),
              ButtonSegment<int>(value: 2, label: Text("High")),
            ],
            selected: <int>{priority},
            showSelectedIcon: false,
            onSelectionChanged: (Set<int> selection) =>
                onPriorityChanged(selection.first),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          TextField(
            controller: tags,
            decoration: const InputDecoration(
              labelText: "Tags (comma-separated)",
            ),
          ),
        ],
      ),
    );
  }
}
