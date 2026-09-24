import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/browse/browse_list_page.dart';
import 'package:miru/features/browse/widgets/browse_list_tile.dart';
import 'package:miru/features/browse/widgets/media_poster_card.dart';

void main() {
  testWidgets("MediaPosterCard shows the title and fires onTap", (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: MediaPosterCard(
            picture: Uri.parse(""),
            title: "Poster Title",
            rank: 2,
            score: 8.4,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text("Poster Title"), findsOneWidget);
    expect(find.text("#2"), findsOneWidget);
    expect(find.text("8.4"), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.tap(find.text("Poster Title"));
    expect(taps, 1);
  });

  testWidgets("MediaPosterCard marks items already on the list", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: MediaPosterCard(
            picture: Uri.parse(""),
            title: "Tracked",
            inList: true,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets("BrowseListTile renders metadata and fires onTap", (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: BrowseListTile(
            picture: Uri.parse(""),
            title: "Tile Title",
            rank: 5,
            score: 7.2,
            mediaType: "tv",
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text("Tile Title"), findsOneWidget);
    expect(find.text("#5"), findsOneWidget);
    expect(find.text("7.2"), findsOneWidget);
    expect(find.text("TV"), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.tap(find.text("Tile Title"));
    expect(taps, 1);
  });

  testWidgets("BrowseListTile marks items already on the list", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: BrowseListTile(
            picture: Uri.parse(""),
            title: "Tracked",
            inList: true,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets("BrowseListPage reloads when a selector changes", (
    WidgetTester tester,
  ) async {
    final List<Object> loads = <Object>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: BrowseListPage<String>(
          title: "Test",
          selectors: <BrowseSelector>[
            BrowseSelector(
              label: "Type",
              options: const <Object>[1, 2],
              value: 1,
              optionLabel: (Object option) => "Type $option",
            ),
          ],
          loader:
              (
                List<Object> selected, {
                required int offset,
                required int limit,
              }) async {
                loads.add(selected.first);
                return <String>["Item ${selected.first}"];
              },
          itemBuilder: (BuildContext context, String item) =>
              ListTile(title: Text(item)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text("Item 1"), findsOneWidget);

    await tester.tap(find.text("Type 1"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("Type 2").last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text("Item 2"), findsOneWidget);
    expect(loads, contains(2));
  });
}
