import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/settings/settings.dart';
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

    final SwitchListTile tile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(tile.value, isFalse);
    expect(controller.edgeSwipeOpensDrawer, isFalse);
  });

  testWidgets("toggling the switch updates the controller", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(controller));

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(controller.edgeSwipeOpensDrawer, isTrue);
    final SwitchListTile tile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(tile.value, isTrue);
  });
}
