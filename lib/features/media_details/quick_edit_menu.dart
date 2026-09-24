import 'package:flutter/material.dart';

/// One row in the long-press quick-edit menu.
class QuickEditAction {
  const QuickEditAction({
    required this.icon,
    required this.label,
    required this.value,
    required this.id,
  });

  final IconData icon;
  final String label;
  final String value;
  final String id;
}

/// Shows the long-press quick-edit menu and returns the chosen action id.
Future<String?> showQuickEditMenu(
  BuildContext context,
  List<QuickEditAction> actions,
) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final QuickEditAction action in actions)
            ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              subtitle: Text(action.value),
              onTap: () => Navigator.of(context).pop(action.id),
            ),
          const SizedBox(height: 8.0),
        ],
      );
    },
  );
}

/// Awaits [future], surfacing a themed error snackbar on failure.
Future<void> applyUpdate(BuildContext context, Future<void> future) async {
  try {
    await future;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update list.")),
      );
    }
  }
}
