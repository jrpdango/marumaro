import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/widgets/loading_popup.dart';

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

    showDialog(
      context: context,
      builder: (_) => const LoadingPopup(),
    );
    try {
      await widget.onSave(updated, patch);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop(updated);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update list.")),
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

  List<DropdownMenuItem<String>> get _statusItems {
    final List<MapEntry<String, String>> options = _isAnime
        ? AnimeListStatus.values
            .map((AnimeListStatus s) => MapEntry(s.apiValue, s.label))
            .toList()
        : MangaListStatus.values
            .map((MangaListStatus s) => MapEntry(s.apiValue, s.label))
            .toList();
    return options
        .map((MapEntry<String, String> option) =>
            _item<String>(option.key, option.value))
        .toList();
  }

  DropdownMenuItem<T> _item<T>(T value, String label) {
    return DropdownMenuItem<T>(
      value: value,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButton<T>(
      value: value,
      isExpanded: true,
      dropdownColor: Colors.grey[850],
      underline: const SizedBox.shrink(),
      style: const TextStyle(color: Colors.white),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _labeled(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _stacked(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          ),
          const SizedBox(height: 6.0),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        isDense: true,
        hintText: "0",
        suffixText: showTotal ? "/ $total" : null,
        suffixStyle: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _dateField({required bool start}) {
    final DateTime? date = start ? _startDate : _finishDate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: () => _pickDate(start: start),
          child: Text(
            date == null ? "Not set" : UserListStatus.serializeDate(date)!,
          ),
        ),
        if (date != null)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white70, size: 18.0),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          TextButton(
            onPressed: _patch.isEmpty ? null : _save,
            child: const Text("Save"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          _labeled(
            "Status",
            _dropdown<String>(
              value: _status,
              items: _statusItems,
              onChanged: (String? value) =>
                  setState(() => _status = value ?? _status),
            ),
          ),
          _labeled(
            "Score",
            _dropdown<int>(
              value: _score,
              items: List<DropdownMenuItem<int>>.generate(
                11,
                (int index) => _item<int>(index, "$index"),
              ),
              onChanged: (int? value) =>
                  setState(() => _score = value ?? _score),
            ),
          ),
          _labeled(
            _isAnime ? "Episodes Watched" : "Chapters Read",
            _numberField(_progress, total: widget.progressTotal),
          ),
          if (!_isAnime)
            _labeled(
              "Volumes Read",
              _numberField(_volumes, total: widget.volumeTotal),
            ),
          _labeled("Start Date", _dateField(start: true)),
          _labeled("Finish Date", _dateField(start: false)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_isAnime ? "Rewatching" : "Rereading"),
            value: _isRewatching,
            onChanged: (bool value) => setState(() => _isRewatching = value),
          ),
          _labeled(
            _isAnime ? "Times Rewatched" : "Times Reread",
            _numberField(_times),
          ),
          _labeled(
            _isAnime ? "Rewatch Value" : "Reread Value",
            _dropdown<int>(
              value: _rewatchValue,
              items: List<DropdownMenuItem<int>>.generate(
                6,
                (int index) => _item<int>(index, "$index"),
              ),
              onChanged: (int? value) =>
                  setState(() => _rewatchValue = value ?? _rewatchValue),
            ),
          ),
          _labeled(
            "Priority",
            _dropdown<int>(
              value: _priority,
              items: <DropdownMenuItem<int>>[
                _item<int>(0, "Low"),
                _item<int>(1, "Medium"),
                _item<int>(2, "High"),
              ],
              onChanged: (int? value) =>
                  setState(() => _priority = value ?? _priority),
            ),
          ),
          _stacked(
            "Tags (comma-separated)",
            TextField(
              controller: _tags,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(isDense: true),
            ),
          ),
          _stacked(
            "Comments",
            TextField(
              controller: _comments,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(isDense: true),
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
