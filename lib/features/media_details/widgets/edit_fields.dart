part of '../edit_list_page.dart';

/// A titled form section with the trailing gap used between entries.
class _EditSection extends StatelessWidget {
  const _EditSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceXl),
      child: SectionHeader(title: title, child: child),
    );
  }
}

/// A date row: a button showing the date (or "Not set") plus a clear action
/// when a date is set.
class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap, this.onClear});

  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: TextButton(
            onPressed: onTap,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                date == null ? "Not set" : UserListStatus.serializeDate(date)!,
              ),
            ),
          ),
        ),
        if (date != null)
          IconButton(
            icon: Icon(Icons.clear, color: scheme.onSurfaceVariant, size: 18.0),
            onPressed: onClear,
          ),
      ],
    );
  }
}
