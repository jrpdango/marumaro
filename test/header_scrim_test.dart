import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/core/core.dart';

void main() {
  testWidgets("fade scrim fills the header backdrop", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400.0,
              height: 200.0,
              child: const HeaderScrim.fade(),
            ),
          ),
        ),
      ),
    );

    final Finder scrim = find.descendant(
      of: find.byType(HeaderScrim),
      matching: find.byType(DecoratedBox),
    );

    expect(scrim, findsOneWidget);
    expect(tester.getSize(scrim), const Size(400.0, 200.0));
  });

  testWidgets("solid scrim fills its parent", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400.0,
              height: 200.0,
              child: const HeaderScrim(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(HeaderScrim), findsOneWidget);
    expect(find.descendant(
      of: find.byType(HeaderScrim),
      matching: find.byType(ColoredBox),
    ), findsOneWidget);
  });
}
