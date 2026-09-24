import 'package:flutter/material.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/anime_details.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/pages/edit_list_page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/media_details_view.dart';
import 'package:miru/widgets/quick_edit_sheets.dart';

class AnimeDetailsPage extends StatefulWidget {
  const AnimeDetailsPage({super.key, required this.anime});

  final Anime anime;

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  GlobalController? _controller;

  late AnimeListStatus _persistedStatus = widget.anime.userStatus;
  late int _persistedScore = widget.anime.userScore;
  late int _persistedEpsWatched = widget.anime.userEpisodesWatched;

  late AnimeListStatus _chosenStatus = widget.anime.userStatus;
  late int _chosenScore = widget.anime.userScore;
  late int _chosenEpsWatched = widget.anime.userEpisodesWatched;

  bool _saving = false;
  Future<AnimeDetails>? _animeDetails;

  Anime get _anime => widget.anime;

  bool get _dirty =>
      _chosenStatus != _persistedStatus ||
      _chosenScore != _persistedScore ||
      _chosenEpsWatched != _persistedEpsWatched;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    _animeDetails ??=
        _controller!.repository.fetchAnimeDetails(widget.anime.id);
  }

  /// Sends the pending changes to MAL and updates local state.
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _controller!.updateAnime(
        anime: _anime,
        status: _chosenStatus,
        score: _chosenScore,
        episodesWatched: _chosenEpsWatched,
      );
      if (mounted) {
        setState(() {
          _persistedStatus = _chosenStatus;
          _persistedScore = _chosenScore;
          _persistedEpsWatched = _chosenEpsWatched;
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
      _chosenEpsWatched = _persistedEpsWatched;
    });
  }

  void _adjustProgress(int delta) {
    final int total = _anime.totalEpisodes;
    setState(() {
      final int next = _chosenEpsWatched + delta;
      _chosenEpsWatched =
          total > 0 ? next.clamp(0, total) : (next < 0 ? 0 : next);
    });
  }

  void _showStatus() {
    showStatusSheet(
      context,
      kind: MediaKind.anime,
      current: _chosenStatus.apiValue,
      onSelected: (String value) => setState(
        () => _chosenStatus = AnimeListStatus.fromApiValue(value),
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

  void _showEpisodes() {
    showProgressSheet(
      context,
      label: "Episodes Watched",
      total: _anime.totalEpisodes,
      initial: _chosenEpsWatched,
      onChanged: (int value) => setState(() => _chosenEpsWatched = value),
    );
  }

  /// Builds the starting status for the edit form from the current in-progress
  /// values (carrying over unsaved popup edits) plus the server's advanced
  /// fields.
  UserListStatus _initialStatus(AnimeDetails details) {
    final UserListStatus? server = details.myListStatus;
    return UserListStatus(
      status: _chosenStatus.apiValue,
      score: _chosenScore,
      progress: _chosenEpsWatched,
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
    final Future<AnimeDetails>? future = _animeDetails;
    if (future == null) return;
    final AnimeDetails details;
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
          title: _anime.title,
          kind: MediaKind.anime,
          initial: _initialStatus(details),
          baseline: details.myListStatus,
          progressTotal: _anime.totalEpisodes,
          onSave: (UserListStatus status, Map<String, String> patch) =>
              _controller!.updateAnimeUserListStatus(
            anime: _anime,
            status: status,
            patch: patch,
          ),
          onRemove: () => _controller!.removeAnime(_anime),
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
      _chosenStatus = AnimeListStatus.fromApiValue(updated.status);
      _chosenScore = updated.score;
      _chosenEpsWatched = updated.progress;
      _persistedStatus = _chosenStatus;
      _persistedScore = _chosenScore;
      _persistedEpsWatched = _chosenEpsWatched;
      _animeDetails =
          _controller!.repository.fetchAnimeDetails(widget.anime.id);
    });
  }

  /// Confirms and removes the anime from the user's list.
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
      await _controller!.removeAnime(_anime);
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
    return FutureBuilder<AnimeDetails>(
      future: _animeDetails,
      builder: (BuildContext context, AsyncSnapshot<AnimeDetails> snapshot) {
        if (snapshot.hasError) {
          return MediaDetailsError(
            title: _anime.title,
            onRetry: () => setState(() {
              _animeDetails =
                  _controller!.repository.fetchAnimeDetails(widget.anime.id);
            }),
          );
        }
        if (!snapshot.hasData) {
          return MediaDetailsLoading(
            title: _anime.title,
            poster: _anime.picture,
          );
        }
        return MediaDetailsView(
          data: snapshot.data!.toViewData(
            id: _anime.id,
            title: _anime.title,
            poster: _anime.picture,
          ),
          statusLabel: _chosenStatus.label,
          score: _chosenScore,
          progress: _chosenEpsWatched,
          progressTotal: _anime.totalEpisodes,
          progressLabel: "Episodes",
          dirty: _dirty,
          saving: _saving,
          onStatusTap: _showStatus,
          onScoreTap: _showScore,
          onProgressTap: _showEpisodes,
          onEditTap: _openEdit,
          onProgressDelta: _adjustProgress,
          onSave: _save,
          onDiscard: _discard,
          onRemove: _remove,
        );
      },
    );
  }
}
