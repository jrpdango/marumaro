import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/models/manga_details.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/pages/edit_list_page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/media_details_view.dart';
import 'package:miru/widgets/quick_edit_sheets.dart';

class MangaDetailsPage extends StatefulWidget {
  const MangaDetailsPage({super.key, required this.manga});

  final Manga manga;

  @override
  State<MangaDetailsPage> createState() => _MangaDetailsPageState();
}

class _MangaDetailsPageState extends State<MangaDetailsPage> {
  GlobalController? _controller;

  late MangaListStatus _persistedStatus = widget.manga.userStatus;
  late int _persistedScore = widget.manga.userScore;
  late int _persistedChapters = widget.manga.userChaptersRead;
  late int _persistedVolumes = widget.manga.userVolumesRead;

  late MangaListStatus _chosenStatus = widget.manga.userStatus;
  late int _chosenScore = widget.manga.userScore;
  late int _chosenChapters = widget.manga.userChaptersRead;
  late int _chosenVolumes = widget.manga.userVolumesRead;

  bool _saving = false;
  Future<MangaDetails>? _mangaDetails;

  Manga get _manga => widget.manga;

  bool get _dirty =>
      _chosenStatus != _persistedStatus ||
      _chosenScore != _persistedScore ||
      _chosenChapters != _persistedChapters ||
      _chosenVolumes != _persistedVolumes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    _mangaDetails ??=
        _controller!.repository.fetchMangaDetails(widget.manga.id);
  }

  /// Sends the pending changes to MAL and updates local state.
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _controller!.updateManga(
        manga: _manga,
        status: _chosenStatus,
        score: _chosenScore,
        chaptersRead: _chosenChapters,
        volumesRead: _chosenVolumes,
      );
      if (mounted) {
        setState(() {
          _persistedStatus = _chosenStatus;
          _persistedScore = _chosenScore;
          _persistedChapters = _chosenChapters;
          _persistedVolumes = _chosenVolumes;
          _saving = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update list.")),
        );
      }
    }
  }

  /// Reverts staged changes back to the last persisted values.
  void _discard() {
    setState(() {
      _chosenStatus = _persistedStatus;
      _chosenScore = _persistedScore;
      _chosenChapters = _persistedChapters;
      _chosenVolumes = _persistedVolumes;
    });
  }

  int _clamp(int value, int total) {
    if (total > 0) return value.clamp(0, total);
    return value < 0 ? 0 : value;
  }

  void _adjustChapters(int delta) {
    setState(() =>
        _chosenChapters = _clamp(_chosenChapters + delta, _manga.totalChapters));
  }

  void _showStatus() {
    showStatusSheet(
      context,
      kind: MediaKind.manga,
      current: _chosenStatus.apiValue,
      onSelected: (String value) => setState(
        () => _chosenStatus = MangaListStatus.fromApiValue(value),
      ),
    );
  }

  void _showScore() {
    showScoreSheet(
      context,
      initial: _chosenScore,
      onChanged: (int value) => setState(() => _chosenScore = value),
    );
  }

  void _showChapters() {
    showProgressSheet(
      context,
      label: "Chapters Read",
      total: _manga.totalChapters,
      initial: _chosenChapters,
      onChanged: (int value) => setState(() => _chosenChapters = value),
    );
  }

  /// Builds the starting status for the edit form from the current in-progress
  /// values (carrying over unsaved popup edits) plus the server's advanced
  /// fields.
  UserListStatus _initialStatus(MangaDetails details) {
    final UserListStatus? server = details.myListStatus;
    return UserListStatus(
      status: _chosenStatus.apiValue,
      score: _chosenScore,
      progress: _chosenChapters,
      volumeProgress: _chosenVolumes,
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
  Future<void> _openEdit() async {
    final Future<MangaDetails>? future = _mangaDetails;
    if (future == null) return;
    final MangaDetails details;
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
          title: _manga.title,
          kind: MediaKind.manga,
          initial: _initialStatus(details),
          baseline: details.myListStatus,
          progressTotal: _manga.totalChapters,
          volumeTotal: _manga.totalVolumes,
          onSave: (UserListStatus status, Map<String, String> patch) =>
              _controller!.updateMangaUserListStatus(
            manga: _manga,
            status: status,
            patch: patch,
          ),
          onRemove: () => _controller!.removeManga(_manga),
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
      _chosenStatus = MangaListStatus.fromApiValue(updated.status);
      _chosenScore = updated.score;
      _chosenChapters = updated.progress;
      _chosenVolumes = updated.volumeProgress ?? _chosenVolumes;
      _persistedStatus = _chosenStatus;
      _persistedScore = _chosenScore;
      _persistedChapters = _chosenChapters;
      _persistedVolumes = _chosenVolumes;
      _mangaDetails =
          _controller!.repository.fetchMangaDetails(widget.manga.id);
    });
  }

  /// Confirms and removes the manga from the user's list.
  Future<void> _remove() async {
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
      await _controller!.removeManga(_manga);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove from list.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MangaDetails>(
      future: _mangaDetails,
      builder: (BuildContext context, AsyncSnapshot<MangaDetails> snapshot) {
        if (snapshot.hasError) {
          return MediaDetailsError(
            title: _manga.title,
            onRetry: () => setState(() {
              _mangaDetails =
                  _controller!.repository.fetchMangaDetails(widget.manga.id);
            }),
          );
        }
        if (!snapshot.hasData) {
          return MediaDetailsLoading(
            title: _manga.title,
            poster: _manga.picture,
          );
        }
        return MediaDetailsView(
          data: snapshot.data!.toViewData(
            id: _manga.id,
            title: _manga.title,
            poster: _manga.picture,
          ),
          statusLabel: _chosenStatus.label,
          score: _chosenScore,
          progress: _chosenChapters,
          progressTotal: _manga.totalChapters,
          progressLabel: "Chapters",
          dirty: _dirty,
          saving: _saving,
          onStatusTap: _showStatus,
          onScoreTap: _showScore,
          onProgressTap: _showChapters,
          onEditTap: _openEdit,
          onProgressDelta: _adjustChapters,
          onSave: _save,
          onDiscard: _discard,
          onRemove: _remove,
        );
      },
    );
  }
}
