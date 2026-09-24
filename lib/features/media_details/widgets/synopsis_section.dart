part of 'media_details_view.dart';

/// The synopsis section, with a "Read more"/"Show less" toggle for long text.
class _SynopsisSection extends StatefulWidget {
  const _SynopsisSection({required this.synopsis});

  final String synopsis;

  @override
  State<_SynopsisSection> createState() => _SynopsisSectionState();
}

class _SynopsisSectionState extends State<_SynopsisSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool collapsible = widget.synopsis.length > 220;
    return SectionHeader(
      title: "Synopsis",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.synopsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            maxLines: !collapsible || _expanded ? null : 4,
            overflow:
                !collapsible || _expanded ? null : TextOverflow.ellipsis,
          ),
          if (collapsible)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? "Show less" : "Read more"),
              ),
            ),
        ],
      ),
    );
  }
}
