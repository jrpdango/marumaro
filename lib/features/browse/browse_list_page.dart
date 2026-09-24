import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';

/// One selectable filter on a [BrowseListPage] (a ranking type, a season, a
/// sort order, ...). Values are compared by identity/equality, so enums and
/// value types like [SeasonRef] work as options.
class BrowseSelector {
  const BrowseSelector({
    required this.label,
    required this.options,
    required this.value,
    required this.optionLabel,
  });

  final String label;
  final List<Object> options;
  final Object value;
  final String Function(Object option) optionLabel;
}

/// A paged browse list driven by one or more [BrowseSelector]s.
///
/// Changing any selector reloads the list from the first page. Used for the
/// ranking and seasonal "View More" pages.
class BrowseListPage<T> extends StatefulWidget {
  const BrowseListPage({
    super.key,
    required this.title,
    required this.selectors,
    required this.loader,
    required this.itemBuilder,
    this.emptyMessage = "Nothing here yet.",
    this.pageSize = 30,
  });

  final String title;
  final List<BrowseSelector> selectors;

  /// Loads a page for the current selector values.
  final Future<List<T>> Function(
    List<Object> selected, {
    required int offset,
    required int limit,
  }) loader;

  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyMessage;
  final int pageSize;

  @override
  State<BrowseListPage<T>> createState() => _BrowseListPageState<T>();
}

class _BrowseListPageState<T> extends State<BrowseListPage<T>> {
  late final List<Object> _selected =
      widget.selectors.map((BrowseSelector selector) => selector.value).toList();
  int _generation = 0;

  void _select(int index, Object value) {
    if (_selected[index] == value) return;
    setState(() {
      _selected[index] = value;
      _generation++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: widget.title),
      body: Column(
        children: <Widget>[
          if (widget.selectors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.spaceLg,
                AppTokens.spaceMd,
                AppTokens.spaceLg,
                AppTokens.spaceSm,
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < widget.selectors.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: AppTokens.spaceMd),
                    Expanded(child: _buildSelector(i)),
                  ],
                ],
              ),
            ),
          Expanded(
            child: PagedListView<T>(
              source: DelegatePagedSource<T>(
                ({required int offset, required int limit}) =>
                    widget.loader(_selected, offset: offset, limit: limit),
              ),
              itemBuilder: widget.itemBuilder,
              pageStorageKey: "browse_list_${widget.title}_$_generation",
              pageSize: widget.pageSize,
              resetKey: _generation,
              emptyMessage: widget.emptyMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector(int index) {
    final BrowseSelector selector = widget.selectors[index];
    return DropdownButtonHideUnderline(
      child: DropdownButton<Object>(
        isExpanded: true,
        value: _selected[index],
        items: selector.options
            .map(
              (Object option) => DropdownMenuItem<Object>(
                value: option,
                child: Text(
                  selector.optionLabel(option),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (Object? value) {
          if (value != null) _select(index, value);
        },
      ),
    );
  }
}
