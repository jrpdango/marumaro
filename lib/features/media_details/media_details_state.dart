import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/media_details/edit_list_page.dart';
import 'package:marumaro/features/media_details/quick_edit_sheets.dart';
import 'package:marumaro/features/media_details/widgets/details_scaffolds.dart';
import 'package:marumaro/features/media_details/widgets/media_details_view.dart';

/// Shared state and behavior for the anime and manga details pages.
///
/// Owns the staged list edits (status, score, progress, optional volumes), the
/// dirty/save/discard flow, the quick-edit sheets, and the full edit form.
/// Concrete pages supply the type-specific hooks below.
mixin MediaDetailsStateMixin<TWidget extends StatefulWidget, TDetails>
    on State<TWidget> {
  bool _initialized = false;
  bool _saving = false;
  bool _inList = true;
  bool _adding = false;
  Future<TDetails>? _detailsFuture;

  late String _persistedStatus;
  late int _persistedScore;
  late int _persistedProgress;
  late int? _persistedVolumes;
  late String _chosenStatus;
  late int _chosenScore;
  late int _chosenProgress;
  late int? _chosenVolumes;

  // --- Type-specific hooks supplied by each page. ---

  GlobalController get controller;
  MediaKind get kind;

  /// Short label for the progress stat, e.g. "Episodes".
  String get progressLabel;

  /// Full label used by the progress editor sheet, e.g. "Episodes Watched".
  String get progressSheetLabel;

  /// Total episodes (anime) or chapters (manga); 0 when unknown.
  int get totalProgress;

  /// Total volumes (manga) or null (anime).
  int? get totalVolumes;

  String get initialStatusValue;
  int get initialScore;
  int get initialProgress;
  int get initialVolumeProgress;

  /// Whether the media is on the user's list when the page opens.
  bool get initialInList;
  int get mediaId;
  String get mediaTitle;
  Uri get mediaPicture;

  String statusLabel(String apiValue);
  MediaDetailsData buildViewData(TDetails details);
  UserListStatus? serverStatus(TDetails details);
  Future<TDetails> loadDetails();
  Future<void> persistDraft({
    required String status,
    required int score,
    required int progress,
    int? volumes,
  });
  Future<void> applyUserListStatus(
    UserListStatus status,
    Map<String, String> patch,
  );
  Future<void> removeFromList();

  // --- Shared state. ---

  /// Whether the media is currently on the user's list. Starts from
  /// [initialInList] and flips to true once an edit has been saved.
  bool get inList => _inList;

  /// Whether the stats/edit controls should be visible. Untracked media hides
  /// them behind the "Add to List" button until [startAddToList] is called.
  bool get showStats => _inList || _adding;

  /// While adding, the entry counts as dirty so the save bar (which adds it) is
  /// always available.
  bool get _dirty =>
      _adding ||
      _chosenStatus != _persistedStatus ||
      _chosenScore != _persistedScore ||
      _chosenProgress != _persistedProgress ||
      _chosenVolumes != _persistedVolumes;

  /// Begins adding untracked media, revealing the stats/edit controls.
  void startAddToList() {
    if (_adding) return;
    setState(() => _adding = true);
  }

  /// The status used when adding untracked media.
  String get _defaultStatusValue => kind == MediaKind.anime
      ? AnimeListStatus.planToWatch.apiValue
      : MangaListStatus.planToRead.apiValue;

  /// Loads details and reconciles the list state with the server before the
  /// future resolves, so the view never renders a stale add/stats state.
  Future<TDetails> _loadAndSync() {
    return loadDetails().then((TDetails details) {
      _applyServerStatus(details);
      return details;
    });
  }

  /// Reconciles the displayed list status/score/progress with the server's
  /// `my_list_status`. This fixes browse entries, whose list membership is
  /// unknown until the details request returns. Skipped while the user has
  /// pending edits.
  void _applyServerStatus(TDetails details) {
    final UserListStatus? server = serverStatus(details);
    if (server == null) {
      if (_inList && !_dirty) {
        _inList = false;
        _persistedStatus = _chosenStatus = _defaultStatusValue;
        _persistedScore = _chosenScore = 0;
        _persistedProgress = _chosenProgress = 0;
        _persistedVolumes = _chosenVolumes = kind == MediaKind.manga ? 0 : null;
      }
      return;
    }
    if (_dirty) return;
    _inList = true;
    _persistedStatus = _chosenStatus = server.status;
    _persistedScore = _chosenScore = server.score;
    _persistedProgress = _chosenProgress = server.progress;
    if (kind == MediaKind.manga) {
      _persistedVolumes = _chosenVolumes = server.volumeProgress;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _inList = initialInList;
    _persistedStatus = _chosenStatus = initialStatusValue;
    _persistedScore = _chosenScore = initialScore;
    _persistedProgress = _chosenProgress = initialProgress;
    _persistedVolumes = _chosenVolumes =
        kind == MediaKind.manga ? initialVolumeProgress : null;
    _detailsFuture = _loadAndSync();
  }

  /// Sends the pending changes to MAL and updates local state.
  Future<void> saveDraft() async {
    setState(() => _saving = true);
    try {
      await persistDraft(
        status: _chosenStatus,
        score: _chosenScore,
        progress: _chosenProgress,
        volumes: _chosenVolumes,
      );
      if (!mounted) return;
      setState(() {
        _inList = true;
        _adding = false;
        _persistedStatus = _chosenStatus;
        _persistedScore = _chosenScore;
        _persistedProgress = _chosenProgress;
        _persistedVolumes = _chosenVolumes;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update list.")),
      );
    }
  }

  /// Reverts staged changes back to the last persisted values. While adding
  /// untracked media, discarding cancels the add entirely.
  void discardDraft() {
    setState(() {
      _adding = false;
      _chosenStatus = _persistedStatus;
      _chosenScore = _persistedScore;
      _chosenProgress = _persistedProgress;
      _chosenVolumes = _persistedVolumes;
    });
  }

  void adjustProgress(int delta) {
    final int total = totalProgress;
    setState(() {
      final int next = _chosenProgress + delta;
      _chosenProgress =
          total > 0 ? next.clamp(0, total) : (next < 0 ? 0 : next);
    });
  }

  void showStatus() {
    showStatusSheet(
      context,
      kind: kind,
      current: _chosenStatus,
      onSelected: (String value) => setState(() => _chosenStatus = value),
    );
  }

  void showScore() {
    showScoreSheet(
      context,
      initial: _chosenScore,
      onChanged: (int value) => setState(() => _chosenScore = value),
    );
  }

  void showProgress() {
    showProgressSheet(
      context,
      label: progressSheetLabel,
      total: totalProgress,
      initial: _chosenProgress,
      onChanged: (int value) => setState(() => _chosenProgress = value),
    );
  }

  /// Builds the starting status for the edit form from the current in-progress
  /// values (carrying over unsaved popup edits) plus the server's advanced
  /// fields.
  UserListStatus _initialStatus(TDetails details) {
    final UserListStatus? server = serverStatus(details);
    return UserListStatus(
      status: _chosenStatus,
      score: _chosenScore,
      progress: _chosenProgress,
      volumeProgress: kind == MediaKind.manga ? _chosenVolumes : null,
      startDate: server?.startDate,
      finishDate: server?.finishDate,
      isRewatching: server?.isRewatching ?? false,
      timesRewatched: server?.timesRewatched ?? 0,
      rewatchValue: server?.rewatchValue ?? 0,
      priority: server?.priority ?? 0,
      tags: server?.tags ?? "",
      comments: server?.comments ?? "",
    );
  }

  /// Opens the full edit form, then applies the result locally.
  Future<void> openEdit() async {
    final Future<TDetails>? future = _detailsFuture;
    if (future == null) return;
    final TDetails details;
    try {
      details = await future;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error loading data. Please try again later.")),
        );
      }
      return;
    }
    if (!mounted) return;

    final Object? result = await Navigator.of(context).push<Object>(
      MaterialPageRoute<Object>(
        builder: (_) => EditListPage(
          title: mediaTitle,
          kind: kind,
          initial: _initialStatus(details),
          baseline: serverStatus(details),
          progressTotal: totalProgress,
          volumeTotal: totalVolumes,
          onSave: applyUserListStatus,
          onRemove: removeFromList,
        ),
      ),
    );
    if (result == null || !mounted) return;
    if (result is EditListRemoved) {
      Navigator.of(context).pop();
      return;
    }
    final UserListStatus updated = result as UserListStatus;

    setState(() {
      _inList = true;
      _chosenStatus = updated.status;
      _chosenScore = updated.score;
      _chosenProgress = updated.progress;
      _chosenVolumes = kind == MediaKind.manga
          ? (updated.volumeProgress ?? _chosenVolumes)
          : null;
      _persistedStatus = _chosenStatus;
      _persistedScore = _chosenScore;
      _persistedProgress = _chosenProgress;
      _persistedVolumes = _chosenVolumes;
      _detailsFuture = _loadAndSync();
    });
  }

  /// Confirms and removes the item from the user's list.
  Future<void> confirmRemove() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Remove from list?"),
        content: const Text(
          "This deletes your progress, score, and dates for this title on "
          "MyAnimeList. This cannot be undone.",
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await removeFromList();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove from list.")),
        );
      }
    }
  }

  /// Builds the page body, resolving the details future into loading, error, or
  /// the shared [MediaDetailsView].
  Widget buildDetailsBody() {
    return FutureBuilder<TDetails>(
      future: _detailsFuture,
      builder: (BuildContext context, AsyncSnapshot<TDetails> snapshot) {
        if (snapshot.hasError) {
          return MediaDetailsError(
            title: mediaTitle,
            onRetry: () => setState(() => _detailsFuture = _loadAndSync()),
          );
        }
        if (!snapshot.hasData) {
          return MediaDetailsLoading(
            title: mediaTitle,
            poster: mediaPicture,
          );
        }
        return MediaDetailsView(
          data: buildViewData(snapshot.data as TDetails),
          inList: inList,
          showStats: showStats,
          onAddToList: startAddToList,
          statusLabel: statusLabel(_chosenStatus),
          score: _chosenScore,
          progress: _chosenProgress,
          progressTotal: totalProgress,
          progressLabel: progressLabel,
          dirty: _dirty,
          saving: _saving,
          onStatusTap: showStatus,
          onScoreTap: showScore,
          onProgressTap: showProgress,
          onEditTap: openEdit,
          onProgressDelta: adjustProgress,
          onSave: saveDraft,
          onDiscard: discardDraft,
          onRemove: confirmRemove,
        );
      },
    );
  }
}
