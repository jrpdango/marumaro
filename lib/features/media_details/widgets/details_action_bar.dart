part of 'media_details_view.dart';

/// The sticky bar shown while the details page has unsaved changes. It holds
/// only the discard/save controls; the quick edit actions live in the status
/// card so this bar can stay slim.
class _DetailsActionBar extends StatelessWidget {
  const _DetailsActionBar({
    required this.saving,
    required this.onSave,
    required this.onDiscard,
  });

  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.spaceSm,
            AppTokens.spaceSm,
            AppTokens.spaceSm,
            AppTokens.spaceSm,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: saving ? null : onDiscard,
                icon: const Icon(Icons.undo),
                tooltip: "Discard changes",
              ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          height: 16.0,
                          width: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text("Save changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
