part of '../edit_list_page.dart';

/// The rewatch/reread section: the toggle, times, and value slider.
class _RewatchSection extends StatelessWidget {
  const _RewatchSection({
    required this.labels,
    required this.isRewatching,
    required this.onRewatchingChanged,
    required this.times,
    required this.rewatchValue,
    required this.onRewatchValueChanged,
  });

  final MediaKindLabels labels;
  final bool isRewatching;
  final ValueChanged<bool> onRewatchingChanged;
  final TextEditingController times;
  final int rewatchValue;
  final ValueChanged<int> onRewatchValueChanged;

  @override
  Widget build(BuildContext context) {
    return _EditSection(
      title: labels.rewatchSection,
      child: Column(
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(labels.rewatching),
            value: isRewatching,
            onChanged: onRewatchingChanged,
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text(labels.timesField)),
              SizedBox(width: 120.0, child: NumberField(controller: times)),
            ],
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Row(
            children: <Widget>[
              Expanded(child: Text(labels.rewatchValueField)),
              Text("$rewatchValue"),
            ],
          ),
          Slider(
            value: rewatchValue.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: "$rewatchValue",
            onChanged: (double value) => onRewatchValueChanged(value.round()),
          ),
        ],
      ),
    );
  }
}
