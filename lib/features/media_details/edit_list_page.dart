import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/media_details/edit_list_draft.dart';
import 'package:marumaro/features/media_details/widgets/number_field.dart';
import 'package:marumaro/features/media_details/widgets/score_slider.dart';

part 'widgets/edit_action_bar.dart';
part 'widgets/edit_dates_section.dart';
part 'widgets/edit_fields.dart';
part 'widgets/edit_notes_section.dart';
part 'widgets/edit_organization_section.dart';
part 'widgets/edit_progress_section.dart';
part 'widgets/edit_rewatch_section.dart';
part 'widgets/edit_score_section.dart';
part 'widgets/edit_status_section.dart';

/// Returned by [EditListPage] when the user removed the item from their list.
class EditListRemoved {
  const EditListRemoved();
}

/// A full-screen form for editing every field of a list status entry.
///
/// Works for both anime and manga; [MediaKind] selects the labels and the API
/// key names used when building the patch body.
class EditListPage extends StatefulWidget {
  const EditListPage({
    super.key,
    required this.title,
    required this.kind,
    required this.initial,
    required this.onSave,
    required this.onRemove,
    this.baseline,
    this.progressTotal,
    this.volumeTotal,
  });

  final String title;
  final MediaKind kind;

  /// The values the form starts from.
  final UserListStatus initial;

  /// The server values used to decide which fields changed. Defaults to
  /// [initial]. Pass the server state when [initial] carries over unsaved
  /// edits so those edits are still included in the patch.
  final UserListStatus? baseline;

  /// Total episodes (anime) or chapters (manga), shown next to the progress
  /// field. A value of 0 or null means unknown.
  final int? progressTotal;

  /// Total volumes (manga), shown next to the volumes field.
  final int? volumeTotal;

  /// Called with the resulting status and the patch containing only the fields
  /// that changed. Throwing keeps the page open and shows an error.
  final Future<void> Function(UserListStatus updated, Map<String, String> patch)
      onSave;

  /// Removes the item from the user's list on MAL and in the cache.
  final Future<void> Function() onRemove;

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  late String _status =
      EditListDraft.validatedStatus(widget.initial.status, widget.kind);
  late int _score = widget.initial.score;
  late final TextEditingController _progress =
      TextEditingController(text: widget.initial.progress.toString());
  late final TextEditingController _volumes = TextEditingController(
    text: (widget.initial.volumeProgress ?? 0).toString(),
  );
  late DateTime? _startDate = widget.initial.startDate;
  late DateTime? _finishDate = widget.initial.finishDate;
  late bool _isRewatching = widget.initial.isRewatching;
  late final TextEditingController _times =
      TextEditingController(text: widget.initial.timesRewatched.toString());
  late int _rewatchValue = widget.initial.rewatchValue;
  late int _priority = widget.initial.priority;
  late final TextEditingController _tags =
      TextEditingController(text: widget.initial.tags);
  late final TextEditingController _comments =
      TextEditingController(text: widget.initial.comments);
  late final UserListStatus _baseline = widget.baseline ?? widget.initial;

  late final MediaKindLabels _labels = MediaKindLabels(widget.kind);

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in <TextEditingController>[
      _progress,
      _volumes,
      _times,
      _tags,
      _comments,
    ]) {
      controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _volumes.dispose();
    _times.dispose();
    _tags.dispose();
    _comments.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  EditListDraft get _draft => EditListDraft(
        status: _status,
        score: _score,
        progressText: _progress.text,
        volumesText: _volumes.text,
        startDate: _startDate,
        finishDate: _finishDate,
        isRewatching: _isRewatching,
        timesText: _times.text,
        rewatchValue: _rewatchValue,
        priority: _priority,
        tags: _tags.text,
        comments: _comments.text,
      );

  bool get _hasChanges => _draft.isDirty(widget.kind, _baseline);

  Future<void> _save() async {
    final UserListStatus updated = _draft.toStatus(widget.kind);
    final Map<String, String> patch = _draft.patch(widget.kind, _baseline);
    if (patch.isEmpty) return;

    setState(() => _busy = true);
    try {
      await widget.onSave(updated, patch);
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update list.")),
      );
    }
  }

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

    showDialog<void>(
      context: context,
      builder: (_) => const LoadingPopup(message: "Removing"),
    );
    try {
      await widget.onRemove();
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop(const EditListRemoved());
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to remove from list.")),
      );
    }
  }

  Future<void> _pickDate({required bool start}) async {
    final DateTime now = DateTime.now();
    final DateTime current = (start ? _startDate : _finishDate) ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startDate = picked;
      } else {
        _finishDate = picked;
      }
    });
  }

  void _clearDate({required bool start}) {
    setState(() {
      if (start) {
        _startDate = null;
      } else {
        _finishDate = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == "remove") _remove();
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "remove",
                child: Text("Remove from list"),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        children: <Widget>[
          _StatusSection(
            options: EditListDraft.statusOptions(widget.kind),
            selected: _status,
            onSelected: (String value) => setState(() => _status = value),
          ),
          _ScoreSection(
            score: _score,
            onChanged: (int value) => setState(() => _score = value),
          ),
          _ProgressSection(
            labels: _labels,
            progress: _progress,
            progressTotal: widget.progressTotal,
            volumes: _volumes,
            volumeTotal: widget.volumeTotal,
          ),
          _DatesSection(
            start: _startDate,
            finish: _finishDate,
            onPickStart: () => _pickDate(start: true),
            onPickFinish: () => _pickDate(start: false),
            onClearStart:
                _startDate == null ? null : () => _clearDate(start: true),
            onClearFinish:
                _finishDate == null ? null : () => _clearDate(start: false),
          ),
          _RewatchSection(
            labels: _labels,
            isRewatching: _isRewatching,
            onRewatchingChanged: (bool value) =>
                setState(() => _isRewatching = value),
            times: _times,
            rewatchValue: _rewatchValue,
            onRewatchValueChanged: (int value) =>
                setState(() => _rewatchValue = value),
          ),
          _OrganizationSection(
            priority: _priority,
            onPriorityChanged: (int value) => setState(() => _priority = value),
            tags: _tags,
          ),
          _NotesSection(comments: _comments),
        ],
      ),
      bottomNavigationBar: _SaveBar(
        hasChanges: _hasChanges,
        busy: _busy,
        onSave: _save,
      ),
    );
  }
}
