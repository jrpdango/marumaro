import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A digits-only text field with an optional `/ total` suffix.
///
/// Shared by the inline edit form and the quick-edit progress sheet.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    this.total,
    this.autofocus = false,
    this.textAlign = TextAlign.right,
    this.style,
    this.unknownSuffix,
    this.onChanged,
  });

  final TextEditingController controller;

  /// The maximum value; 0 or null means unknown.
  final int? total;

  final bool autofocus;
  final TextAlign textAlign;
  final TextStyle? style;

  /// Suffix shown when [total] is 0 or null. Defaults to no suffix.
  final String? unknownSuffix;

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final int? total = this.total;
    final String? suffix =
        total != null && total > 0 ? "/ $total" : unknownSuffix;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textAlign: textAlign,
      style: style,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: "0",
        suffixText: suffix,
      ),
      onChanged: onChanged,
    );
  }
}
