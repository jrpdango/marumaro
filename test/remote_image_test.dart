import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';

Widget _host({double blurSigma = 0.0}) {
  return MaterialApp(
    home: Scaffold(
      body: RemoteImage(
        uri: Uri.parse("https://example.com/backdrop.jpg"),
        fallback: Uri.parse("https://example.com/poster.jpg"),
        blurSigma: blurSigma,
      ),
    ),
  );
}

void main() {
  testWidgets("does not blur by default", (WidgetTester tester) async {
    await tester.pumpWidget(_host());

    expect(find.byType(ImageFiltered), findsNothing);
  });

  testWidgets("blurs when blurSigma is positive", (WidgetTester tester) async {
    await tester.pumpWidget(_host(blurSigma: 12.0));

    expect(find.byType(ImageFiltered), findsOneWidget);
  });
}
