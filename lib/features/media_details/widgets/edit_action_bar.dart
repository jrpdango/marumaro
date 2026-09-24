part of '../edit_list_page.dart';

/// The sticky save bar, disabled while there are no changes or a save is in
/// flight.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.hasChanges,
    required this.busy,
    required this.onSave,
  });

  final bool hasChanges;
  final bool busy;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        child: FilledButton(
          onPressed: hasChanges && !busy ? onSave : null,
          child: Text(hasChanges ? "Save changes" : "No changes"),
        ),
      ),
    );
  }
}
