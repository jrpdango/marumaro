import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/theme/app_colors.dart';
import 'package:miru/widgets/loading_popup.dart';

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
  late String _status = _validStatus(widget.initial.status);
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

  bool _busy = false;

  bool get _isAnime => widget.kind == MediaKind.anime;

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

  String _validStatus(String value) {
    final bool exists = _isAnime
        ? AnimeListStatus.values.any((AnimeListStatus s) => s.apiValue == value)
        : MangaListStatus.values.any((MangaListStatus s) => s.apiValue == value);
    if (exists) return value;
    return _isAnime
        ? AnimeListStatus.watching.apiValue
        : MangaListStatus.reading.apiValue;
  }

  List<MapEntry<String, String>> get _statusOptions {
    return _isAnime
        ? AnimeListStatus.values
            .map((AnimeListStatus s) => MapEntry(s.apiValue, s.label))
            .toList()
        : MangaListStatus.values
            .map((MangaListStatus s) => MapEntry(s.apiValue, s.label))
            .toList();
  }

  UserListStatus _buildUpdated() {
    return UserListStatus(
      status: _status,
      score: _score,
      progress: int.tryParse(_progress.text) ?? 0,
      volumeProgress:
          _isAnime ? null : (int.tryParse(_volumes.text) ?? 0),
      startDate: _startDate,
      finishDate: _finishDate,
      isRewatching: _isRewatching,
      timesRewatched: int.tryParse(_times.text) ?? 0,
      rewatchValue: _rewatchValue,
      priority: _priority,
      tags: _tags.text,
      comments: _comments.text,
    );
  }

  Map<String, String> get _patch =>
      _buildUpdated().changedPatch(widget.kind, _baseline);

  Future<void> _save() async {
    final UserListStatus updated = _buildUpdated();
    final Map<String, String> patch =
        updated.changedPatch(widget.kind, _baseline);
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

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTokens.spaceMd),
          child,
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController controller, {int? total}) {
    final bool showTotal = total != null && total > 0;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: "0",
        suffixText: showTotal ? "/ $total" : null,
      ),
    );
  }

  Widget _dateField({required bool start}) {
    final DateTime? date = start ? _startDate : _finishDate;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: TextButton(
            onPressed: () => _pickDate(start: start),
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
            onPressed: () => setState(() {
              if (start) {
                _startDate = null;
              } else {
                _finishDate = null;
              }
            }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChanges = _patch.isNotEmpty;
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
          _section(
            "Status",
            Wrap(
              spacing: AppTokens.spaceSm,
              runSpacing: AppTokens.spaceSm,
              children: _statusOptions
                  .map(
                    (MapEntry<String, String> option) => ChoiceChip(
                      label: Text(option.value),
                      selected: _status == option.key,
                      onSelected: (_) =>
                          setState(() => _status = option.key),
                    ),
                  )
                  .toList(),
            ),
          ),
          _section(
            "Score",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Spacer(),
                    Text(
                      "$_score",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Slider(
                  value: _score.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: "$_score",
                  onChanged: (double value) =>
                      setState(() => _score = value.round()),
                ),
              ],
            ),
          ),
          _section(
            "Progress",
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(_isAnime
                          ? "Episodes Watched"
                          : "Chapters Read"),
                    ),
                    SizedBox(
                      width: 120.0,
                      child: _numberField(_progress,
                          total: widget.progressTotal),
                    ),
                  ],
                ),
                if (!_isAnime) ...<Widget>[
                  const SizedBox(height: AppTokens.spaceSm),
                  Row(
                    children: <Widget>[
                      const Expanded(child: Text("Volumes Read")),
                      SizedBox(
                        width: 120.0,
                        child: _numberField(_volumes,
                            total: widget.volumeTotal),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _section(
            "Dates",
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const SizedBox(width: 96.0, child: Text("Start")),
                    Expanded(child: _dateField(start: true)),
                  ],
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Row(
                  children: <Widget>[
                    const SizedBox(width: 96.0, child: Text("Finish")),
                    Expanded(child: _dateField(start: false)),
                  ],
                ),
              ],
            ),
          ),
          _section(
            _isAnime ? "Rewatch" : "Reread",
            Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_isAnime ? "Rewatching" : "Rereading"),
                  value: _isRewatching,
                  onChanged: (bool value) =>
                      setState(() => _isRewatching = value),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          _isAnime ? "Times Rewatched" : "Times Reread"),
                    ),
                    SizedBox(
                      width: 120.0,
                      child: _numberField(_times),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          _isAnime ? "Rewatch Value" : "Reread Value"),
                    ),
                    Text("$_rewatchValue"),
                  ],
                ),
                Slider(
                  value: _rewatchValue.toDouble(),
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: "$_rewatchValue",
                  onChanged: (double value) =>
                      setState(() => _rewatchValue = value.round()),
                ),
              ],
            ),
          ),
          _section(
            "Organization",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Priority"),
                const SizedBox(height: AppTokens.spaceSm),
                SegmentedButton<int>(
                  segments: const <ButtonSegment<int>>[
                    ButtonSegment<int>(value: 0, label: Text("Low")),
                    ButtonSegment<int>(value: 1, label: Text("Medium")),
                    ButtonSegment<int>(value: 2, label: Text("High")),
                  ],
                  selected: <int>{_priority},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<int> selection) =>
                      setState(() => _priority = selection.first),
                ),
                const SizedBox(height: AppTokens.spaceLg),
                TextField(
                  controller: _tags,
                  decoration: const InputDecoration(
                    labelText: "Tags (comma-separated)",
                  ),
                ),
              ],
            ),
          ),
          _section(
            "Notes",
            TextField(
              controller: _comments,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Your comments",
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          child: FilledButton(
            onPressed: hasChanges && !_busy ? _save : null,
            child: Text(hasChanges ? "Save changes" : "No changes"),
          ),
        ),
      ),
    );
  }
}
