import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';

Widget _viewer({Object? heroTag}) {
  return MaterialApp(
    home: ImageViewer(
      uri: Uri.parse("https://example.com/large.jpg"),
      fallback: Uri.parse("https://example.com/poster.jpg"),
      heroTag: heroTag,
    ),
  );
}

Widget _host() {
  return MaterialApp(
    home: Builder(
      builder: (BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => ImageViewer(
                  uri: Uri.parse("https://example.com/large.jpg"),
                  fallback: Uri.parse("https://example.com/poster.jpg"),
                ),
              ),
            ),
            child: const Text("Open"),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets("renders a zoomable image", (WidgetTester tester) async {
    await tester.pumpWidget(_viewer());
    await tester.pump();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets("wraps the image in a hero when a tag is given",
      (WidgetTester tester) async {
    await tester.pumpWidget(_viewer(heroTag: "poster"));
    await tester.pump();

    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets("close button pops the viewer", (WidgetTester tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();

    expect(find.byType(ImageViewer), findsOneWidget);

    await tester.tap(find.byTooltip("Close"));
    await tester.pumpAndSettle();

    expect(find.byType(ImageViewer), findsNothing);
  });
}
