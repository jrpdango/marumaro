import 'package:flutter/material.dart';

/// Loads a slice of a larger collection, used by [PagedListView].
abstract class PagedSource<T> {
  Future<List<T>> load({required int offset, required int limit});
}

/// A [PagedSource] backed by a loader callback.
class DelegatePagedSource<T> extends PagedSource<T> {
  DelegatePagedSource(this._load);

  final Future<List<T>> Function({
    required int offset,
    required int limit,
  }) _load;

  @override
  Future<List<T>> load({required int offset, required int limit}) {
    return _load(offset: offset, limit: limit);
  }
}

/// A lazily-paged, pull-to-refreshable list.
///
/// [resetKey] changing clears the list and reloads from the first page (used
/// when the query changes). [reloadListenable] firing refreshes the currently
/// loaded window in place so scroll position is preserved (used when the
/// controller's cached data changes).
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    super.key,
    required this.source,
    required this.itemBuilder,
    required this.pageStorageKey,
    this.onRefresh,
    this.emptyMessage = "Nothing here yet.",
    this.pageSize = 30,
    this.itemExtent,
    this.reloadListenable,
    this.resetKey,
  });

  final PagedSource<T> source;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String pageStorageKey;
  final Future<void> Function()? onRefresh;
  final String emptyMessage;
  final int pageSize;
  final double? itemExtent;
  final Listenable? reloadListenable;
  final Object? resetKey;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = <T>[];

  bool _loading = false;
  bool _hasMore = true;
  Object? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    widget.reloadListenable?.addListener(_handleReload);
    _loadMore();
  }

  @override
  void didUpdateWidget(PagedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadListenable != widget.reloadListenable) {
      oldWidget.reloadListenable?.removeListener(_handleReload);
      widget.reloadListenable?.addListener(_handleReload);
    }
    if (oldWidget.resetKey != widget.resetKey) {
      _reset();
    }
  }

  @override
  void dispose() {
    widget.reloadListenable?.removeListener(_handleReload);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 400) {
      _loadMore();
    }
  }

  void _handleReload() {
    _reloadInPlace();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    final int generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<T> page = await widget.source
          .load(offset: _items.length, limit: widget.pageSize);
      if (!mounted || generation != _generation) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length == widget.pageSize;
        _loading = false;
      });
      _scheduleViewportFill();
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _reloadInPlace() async {
    final int generation = ++_generation;
    final int count = _items.isEmpty ? widget.pageSize : _items.length;
    try {
      final List<T> refreshed =
          await widget.source.load(offset: 0, limit: count);
      if (!mounted || generation != _generation) return;
      setState(() {
        _items
          ..clear()
          ..addAll(refreshed);
        _hasMore = refreshed.length == count;
        _loading = false;
        _error = null;
      });
      _scheduleViewportFill();
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() => _loading = false);
    }
  }

  void _reset() {
    _generation++;
    setState(() {
      _items.clear();
      _hasMore = true;
      _loading = false;
      _error = null;
    });
    _loadMore();
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      try {
        await widget.onRefresh!();
      } catch (_) {}
    }
    _generation++;
    if (!mounted) return;
    setState(() {
      _items.clear();
      _hasMore = true;
      _loading = false;
      _error = null;
    });
    await _loadMore();
  }

  void _scheduleViewportFill() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_hasMore && _scrollController.position.maxScrollExtent <= 0) {
        _loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      if (_loading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (_error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("Failed to load."),
              TextButton(
                onPressed: _reset,
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.35),
            Center(
              child: Text(
                widget.emptyMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        key: PageStorageKey<String>(widget.pageStorageKey),
        physics: const AlwaysScrollableScrollPhysics(),
        itemExtent: widget.itemExtent,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index >= _items.length) return _buildFooter();
          return widget.itemBuilder(context, _items[index]);
        },
      ),
    );
  }

  Widget _buildFooter() {
    if (_error != null) {
      return Center(
        child: TextButton(
          onPressed: _loadMore,
          child: const Text("Retry"),
        ),
      );
    }
    if (_loading) {
      return const Center(
        child: SizedBox(
          height: 22.0,
          width: 22.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
