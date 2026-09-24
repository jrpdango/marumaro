import 'package:flutter/material.dart';
import 'package:miru/core/theme/app_colors.dart';

/// A small themed, non-dismissible loading dialog.
class LoadingPopup extends StatelessWidget {
  const LoadingPopup({super.key, this.message = "Loading"});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceXl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
              const SizedBox(width: AppTokens.spaceLg),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}
