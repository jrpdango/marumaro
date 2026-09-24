part of '../edit_list_page.dart';

/// The dates section: start and finish date rows.
class _DatesSection extends StatelessWidget {
  const _DatesSection({
    required this.start,
    required this.finish,
    required this.onPickStart,
    required this.onPickFinish,
    this.onClearStart,
    this.onClearFinish,
  });

  final DateTime? start;
  final DateTime? finish;
  final VoidCallback onPickStart;
  final VoidCallback onPickFinish;
  final VoidCallback? onClearStart;
  final VoidCallback? onClearFinish;

  @override
  Widget build(BuildContext context) {
    return _EditSection(
      title: "Dates",
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(width: 96.0, child: Text("Start")),
              Expanded(
                child: _DateField(
                  date: start,
                  onTap: onPickStart,
                  onClear: onClearStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Row(
            children: <Widget>[
              const SizedBox(width: 96.0, child: Text("Finish")),
              Expanded(
                child: _DateField(
                  date: finish,
                  onTap: onPickFinish,
                  onClear: onClearFinish,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
