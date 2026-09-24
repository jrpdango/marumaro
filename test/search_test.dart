import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/pages/search.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/theme/app_theme.dart';

/// A controller whose searches resolve immediately, avoiding a real database.
class _FakeController extends GlobalController {
  @override
  Future<List<Anime>> searchAnime(
    String query, {
    required int offset,
    required int limit,
  }) async {
    return const <Anime>[];
  }

  @override
  Future<List<Manga>> searchManga(
    String query, {
    required int offset,
    required int limit,
  }) async {
    return const <Manga>[];
  }
}

void main() {
  late _FakeController controller;

  setUp(() {
    controller = _FakeController();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget host() {
    return GlobalControllerScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Search(),
      ),
    );
  }

  testWidgets("shows the empty state and toggles between anime and manga",
      (WidgetTester tester) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await tester.pump();

    expect(find.text("Search your anime list..."), findsOneWidget);
    expect(find.text("No matches."), findsOneWidget);

    await tester.tap(find.text("Manga"));
    await tester.pump();
    await tester.pump();

    expect(find.text("Search your manga list..."), findsOneWidget);
    expect(find.text("No matches."), findsOneWidget);
  });

  testWidgets("shows a clear button once text is entered",
      (WidgetTester tester) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), "naruto");
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsNothing);
  });
}
