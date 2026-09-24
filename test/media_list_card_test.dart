import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/theme/app_theme.dart';
import 'package:miru/widgets/media_list_card.dart';
import 'package:miru/widgets/media_progress_bar.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets("renders title, status, score, and progress",
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      MediaListCard(
        picture: Uri.parse(""),
        title: "My Anime",
        progressText: "3/12",
        progressValue: 0.25,
        score: "8",
        statusLabel: "Currently Watching",
        heroTag: "media-anime-1",
        onTap: () {},
      ),
    ));
    await tester.pump();

    expect(find.text("My Anime"), findsOneWidget);
    expect(find.text("Currently Watching"), findsOneWidget);
    expect(find.text("8"), findsOneWidget);
    expect(find.text("3/12"), findsOneWidget);

    final LinearProgressIndicator bar =
        tester.widget(find.byType(LinearProgressIndicator));
    expect(bar.value, 0.25);
  });

  testWidgets("shows the volume text for manga", (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      MediaListCard(
        picture: Uri.parse(""),
        title: "My Manga",
        progressText: "5/30",
        progressValue: 5 / 30,
        volumeText: "Vol 2/4",
        score: "9",
        statusLabel: "Currently Reading",
        heroTag: "media-manga-1",
        onTap: () {},
      ),
    ));
    await tester.pump();

    expect(find.textContaining("Vol 2/4"), findsOneWidget);
  });

  testWidgets("onTap and onLongPress fire", (WidgetTester tester) async {
    int taps = 0;
    int longPresses = 0;
    await tester.pumpWidget(_host(
      MediaListCard(
        picture: Uri.parse(""),
        title: "Tappable",
        progressText: "0/1",
        score: "0",
        statusLabel: "Plan To Watch",
        heroTag: "media-anime-2",
        onTap: () => taps++,
        onLongPress: () => longPresses++,
      ),
    ));
    await tester.pump();

    await tester.tap(find.byType(MediaListCard));
    await tester.longPress(find.byType(MediaListCard));

    expect(taps, 1);
    expect(longPresses, 1);
  });

  testWidgets("uses a static track when the total is unknown",
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      MediaListCard(
        picture: Uri.parse(""),
        title: "Unknown",
        progressText: "4",
        progressValue: null,
        score: "0",
        statusLabel: "On Hold",
        heroTag: "media-anime-3",
        onTap: () {},
      ),
    ));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(MediaProgressBar), findsOneWidget);
  });
}
