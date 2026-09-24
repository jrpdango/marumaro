import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/media_details/media_details.dart';

MediaDetailsData _data() {
  return MediaDetailsData(
    kind: MediaKind.anime,
    id: 1,
    title: "Test Anime",
    poster: Uri.parse(""),
    backdrop: Uri.parse(""),
    meanScore: 8.5,
    statusLabel: "Currently Airing",
    infoRows: const <MapEntry<String, String>>[
      MapEntry<String, String>("Episodes", "12"),
      MapEntry<String, String>("Rank", "5"),
    ],
    rank: 5,
    genres: const <String>["Action", "Adventure"],
    synopsis: "A short synopsis.",
  );
}

Widget _host({
  bool dirty = false,
  bool inList = true,
  bool showStats = true,
  int progress = 3,
  int progressTotal = 12,
  VoidCallback? onStatusTap,
  VoidCallback? onScoreTap,
  VoidCallback? onEditTap,
  VoidCallback? onAddToList,
  ValueChanged<int>? onProgressDelta,
  VoidCallback? onSave,
  VoidCallback? onDiscard,
  VoidCallback? onRemove,
}) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: MediaDetailsView(
      data: _data(),
      inList: inList,
      showStats: showStats,
      onAddToList: onAddToList,
      statusLabel: "Watching",
      score: 7,
      progress: progress,
      progressTotal: progressTotal,
      progressLabel: "Episodes",
      dirty: dirty,
      onStatusTap: onStatusTap ?? () {},
      onScoreTap: onScoreTap ?? () {},
      onEditTap: onEditTap ?? () {},
      onProgressDelta: onProgressDelta ?? (_) {},
      onSave: onSave ?? () {},
      onDiscard: onDiscard ?? () {},
      onRemove: onRemove ?? () {},
    ),
  );
}

void main() {
  testWidgets("renders the header and all sections", (WidgetTester tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    expect(find.text("Test Anime"), findsWidgets);
    expect(find.text("Synopsis"), findsOneWidget);
    expect(find.text("A short synopsis."), findsOneWidget);
    expect(find.text("Genres"), findsOneWidget);
    expect(find.text("Action"), findsOneWidget);
    expect(find.text("Adventure"), findsOneWidget);
    expect(find.text("Information"), findsOneWidget);
    expect(find.text("12"), findsWidgets);
  });

  testWidgets("does not show a save bar when clean", (WidgetTester tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    expect(find.text("Save changes"), findsNothing);
    expect(find.byTooltip("Discard changes"), findsNothing);
    expect(find.text("Watching"), findsWidgets);
  });

  testWidgets("shows the save bar when dirty and saves", (WidgetTester tester) async {
    int saves = 0;
    int discards = 0;
    await tester.pumpWidget(_host(
      dirty: true,
      onSave: () => saves++,
      onDiscard: () => discards++,
    ));
    await tester.pump();

    expect(find.text("Save changes"), findsOneWidget);

    await tester.tap(find.text("Save changes"));
    await tester.tap(find.byTooltip("Discard changes"));

    expect(saves, 1);
    expect(discards, 1);
  });

  testWidgets("quick actions invoke their callbacks", (WidgetTester tester) async {
    int statuses = 0;
    int scores = 0;
    int edits = 0;
    final List<int> deltas = <int>[];
    await tester.pumpWidget(_host(
      onStatusTap: () => statuses++,
      onScoreTap: () => scores++,
      onEditTap: () => edits++,
      onProgressDelta: deltas.add,
    ));
    await tester.pump();

    await tester.tap(find.text("Status"));
    await tester.tap(find.text("Score"));
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.tap(find.byTooltip("Increase Episodes"));

    expect(statuses, 1);
    expect(scores, 1);
    expect(edits, 1);
    expect(deltas, <int>[1]);
  });

  testWidgets("inline stepper stays enabled at the bounds", (WidgetTester tester) async {
    final List<int> deltas = <int>[];

    await tester.pumpWidget(_host(progress: 0, onProgressDelta: deltas.add));
    await tester.pump();
    await tester.tap(find.byTooltip("Decrease Episodes"));

    await tester.pumpWidget(
      _host(progress: 12, progressTotal: 12, onProgressDelta: deltas.add),
    );
    await tester.pump();
    await tester.tap(find.byTooltip("Increase Episodes"));

    expect(deltas, <int>[-1, 1]);
  });

  testWidgets("untracked media shows Add to List instead of stats",
      (WidgetTester tester) async {
    int adds = 0;
    await tester.pumpWidget(_host(
      inList: false,
      showStats: false,
      onAddToList: () => adds++,
    ));
    await tester.pump();

    expect(find.text("Add to List"), findsOneWidget);
    expect(find.text("Status"), findsNothing);
    expect(find.text("Watching"), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);

    await tester.tap(find.text("Add to List"));
    expect(adds, 1);
  });

  testWidgets("adding hides remove but shows the stats and edit",
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(inList: false, showStats: true));
    await tester.pump();

    expect(find.text("Add to List"), findsNothing);
    expect(find.text("Status"), findsOneWidget);
    expect(find.text("Watching"), findsWidgets);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets("remove is offered via the overflow menu", (WidgetTester tester) async {
    int removals = 0;
    await tester.pumpWidget(_host(onRemove: () => removals++));
    await tester.pump();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Remove from list"));
    await tester.pumpAndSettle();

    expect(removals, 1);
  });
}
