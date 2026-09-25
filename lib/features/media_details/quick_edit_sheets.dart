import 'package:flutter/material.dart';
import 'package:tamarun/core/core.dart';
import 'package:tamarun/features/media_details/widgets/number_field.dart';
import 'package:tamarun/features/media_details/widgets/score_slider.dart';

/// Shows the list-status picker as a modal bottom sheet.
Future<void> showStatusSheet(
  BuildContext context, {
  required MediaKind kind,
  required String current,
  required ValueChanged<String> onSelected,
}) {
  final List<MapEntry<String, String>> options = kind == MediaKind.anime
      ? AnimeListStatus.values
          .map((AnimeListStatus s) => MapEntry(s.apiValue, s.label))
          .toList()
      : MangaListStatus.values
          .map((MangaListStatus s) => MapEntry(s.apiValue, s.label))
          .toList();
  final ColorScheme scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.spaceLg,
              AppTokens.spaceSm,
              AppTokens.spaceLg,
              AppTokens.spaceSm,
            ),
            child: Text(
              "Status",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final MapEntry<String, String> option in options)
            ListTile(
              title: Text(option.value),
              trailing: option.key == current
                  ? Icon(Icons.check, color: scheme.primary)
                  : null,
              onTap: () {
                onSelected(option.key);
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: AppTokens.spaceSm),
        ],
      );
    },
  );
}

/// Shows the score picker as a modal bottom sheet.
Future<void> showScoreSheet(
  BuildContext context, {
  required int initial,
  required ValueChanged<int> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (BuildContext context) =>
        _ScoreSheet(initial: initial, onChanged: onChanged),
  );
}

/// Shows the progress editor as a modal bottom sheet.
Future<void> showProgressSheet(
  BuildContext context, {
  required String label,
  required int total,
  required int initial,
  required ValueChanged<int> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) => _ProgressSheet(
      label: label,
      total: total,
      initial: initial,
      onChanged: onChanged,
    ),
  );
}

class _ScoreSheet extends StatefulWidget {
  const _ScoreSheet({required this.initial, required this.onChanged});

  final int initial;
  final ValueChanged<int> onChanged;

  @override
  State<_ScoreSheet> createState() => _ScoreSheetState();
}

class _ScoreSheetState extends State<_ScoreSheet> {
  late int _score = widget.initial;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        AppTokens.spaceSm,
        AppTokens.spaceLg,
        AppTokens.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Score", style: text.titleMedium),
          const SizedBox(height: AppTokens.spaceLg),
          Center(
            child: Text(
              "$_score",
              style: text.displaySmall,
            ),
          ),
          ScoreSlider(
            score: _score,
            onChanged: (int value) => setState(() => _score = value),
          ),
          FilledButton(
            onPressed: () {
              widget.onChanged(_score);
              Navigator.of(context).pop();
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}

class _ProgressSheet extends StatefulWidget {
  const _ProgressSheet({
    required this.label,
    required this.total,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final int total;
  final int initial;
  final ValueChanged<int> onChanged;

  @override
  State<_ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<_ProgressSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial.toString());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_controller.text) ?? 0;

  bool get _valid => widget.total == 0 || _value <= widget.total;

  void _step(int delta) {
    final int next = (_value + delta).clamp(0, widget.total == 0 ? 9999 : widget.total);
    _controller.text = "$next";
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        AppTokens.spaceSm,
        AppTokens.spaceLg,
        AppTokens.spaceLg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.label, style: text.titleMedium),
          const SizedBox(height: AppTokens.spaceLg),
          Row(
            children: <Widget>[
              IconButton.filledTonal(
                onPressed: _value > 0 ? () => _step(-1) : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: NumberField(
                  controller: _controller,
                  total: widget.total,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall,
                  unknownSuffix: "/ -",
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _valid && (widget.total == 0 || _value < widget.total)
                    ? () => _step(1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (!_valid)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.spaceSm),
              child: Text(
                "The maximum is ${widget.total}.",
                style: text.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
          const SizedBox(height: AppTokens.spaceLg),
          FilledButton(
            onPressed: _valid
                ? () {
                    widget.onChanged(_value);
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
