part of 'media_details_view.dart';

/// The genres section: a wrapping row of chips.
class _GenresSection extends StatelessWidget {
  const _GenresSection({required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: "Genres",
      child: Wrap(
        spacing: AppTokens.spaceSm,
        runSpacing: AppTokens.spaceSm,
        children: genres
            .map((String genre) => Chip(label: Text(genre)))
            .toList(),
      ),
    );
  }
}

/// The alternative titles section: English, Japanese, and synonyms.
class _AltTitlesSection extends StatelessWidget {
  const _AltTitlesSection({required this.data});

  final MediaDetailsData data;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<MapEntry<String, String>> rows = <MapEntry<String, String>>[
      if (data.englishTitle != null)
        MapEntry("English", data.englishTitle!),
      if (data.japaneseTitle != null)
        MapEntry("Japanese", data.japaneseTitle!),
      if (data.synonyms.isNotEmpty)
        MapEntry("Synonyms", data.synonyms.join(", ")),
    ];
    return SectionHeader(
      title: "Alternative Titles",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map(
              (MapEntry<String, String> row) => Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.spaceSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 80.0,
                      child: Text(
                        row.key,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(row.value, style: text.bodyMedium),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// The information section: the key/value rows in a card.
class _InformationSection extends StatelessWidget {
  const _InformationSection({required this.rows});

  final List<MapEntry<String, String>> rows;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return SectionHeader(
      title: "Information",
      child: Card(
        child: Column(
          children: <Widget>[
            for (int i = 0; i < rows.length; i++) ...<Widget>[
              if (i > 0)
                Divider(height: 1.0, color: scheme.outlineVariant),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.spaceLg,
                  vertical: AppTokens.spaceMd,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        rows[i].key,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rows[i].value,
                        textAlign: TextAlign.right,
                        style: text.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
