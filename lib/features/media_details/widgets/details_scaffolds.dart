import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';

/// A themed loading scaffold shown while details are being fetched.
class MediaDetailsLoading extends StatelessWidget {
  const MediaDetailsLoading({
    super.key,
    required this.title,
    required this.poster,
  });

  final String title;
  final Uri poster;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// A themed error scaffold with a retry action.
class MediaDetailsError extends StatelessWidget {
  const MediaDetailsError({
    super.key,
    required this.title,
    required this.onRetry,
  });

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text("Couldn't load details."),
            const SizedBox(height: AppTokens.spaceSm),
            FilledButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
