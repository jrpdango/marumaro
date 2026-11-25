import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/settings/settings.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Widget _host(GlobalController controller) {
  return GlobalControllerScope(
    controller: controller,
    child: MaterialApp(theme: AppTheme.dark, home: const SettingsPage()),
  );
}

void main() {
  sqfliteFfiInit();

  late LocalStore store;
  late GlobalController controller;

  setUp(() {
    store = LocalStore(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    controller = GlobalController(store: store);
  });

  tearDown(() async {
    controller.dispose();
    await store.close();
  });

  testWidgets("edge swipe switch is off by default", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(controller));

    final Finder edgeSwipe = find.widgetWithText(
      SwitchListTile,
      "Swipe from edge to open menu",
    );
    final SwitchListTile tile = tester.widget<SwitchListTile>(edgeSwipe);
    expect(tile.value, isFalse);
    expect(controller.edgeSwipeOpensDrawer, isFalse);
  });

  testWidgets("toggling the edge swipe switch updates the controller", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(controller));

    final Finder edgeSwipe = find.widgetWithText(
      SwitchListTile,
      "Swipe from edge to open menu",
    );
    await tester.tap(edgeSwipe);
    await tester.pump();

    expect(controller.edgeSwipeOpensDrawer, isTrue);
    final SwitchListTile tile = tester.widget<SwitchListTile>(edgeSwipe);
    expect(tile.value, isTrue);
  });

  testWidgets("NSFW switch is off by default and updates the controller", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(controller));

    final Finder nsfw = find.widgetWithText(
      SwitchListTile,
      "Show adult titles (NSFW)",
    );
    expect(tester.widget<SwitchListTile>(nsfw).value, isFalse);
    expect(controller.showNsfw, isFalse);

    await tester.tap(nsfw);
    await tester.pump();

    expect(controller.showNsfw, isTrue);
    expect(tester.widget<SwitchListTile>(nsfw).value, isTrue);
  });
}
