part of 'media_details_view.dart';

/// The card shown for media that is not on the user's list: a prominent
/// secondary-colored button that reveals the stats/edit controls when tapped.
class _AddToListCard extends StatelessWidget {
  const _AddToListCard({required this.onAddToList});

  final VoidCallback onAddToList;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onAddToList,
            icon: const Icon(Icons.add),
            label: const Text("Add to List"),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.secondary,
              foregroundColor: scheme.onSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
