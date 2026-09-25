import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamarun/core/core.dart';

void main() {
  test("builds light, dark, and AMOLED themes with the right brightness", () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.amoled.brightness, Brightness.dark);

    expect(AppTheme.light.colorScheme.surface, AppColors.lightSurface);
    expect(AppTheme.dark.colorScheme.surface, AppColors.darkSurface);
    expect(AppTheme.amoled.colorScheme.surface, AppColors.amoledSurface);
    expect(AppTheme.amoled.colorScheme.surface, const Color(0xFF000000));
  });

  test("uses Material 3", () {
    expect(AppTheme.dark.useMaterial3, isTrue);
    expect(AppTheme.light.useMaterial3, isTrue);
  });

  test("resolve maps modes to themes", () {
    expect(
      AppTheme.resolve(AppThemeMode.light, Brightness.dark).brightness,
      Brightness.light,
    );
    expect(
      AppTheme.resolve(AppThemeMode.dark, Brightness.light).colorScheme.surface,
      AppColors.darkSurface,
    );
    expect(
      AppTheme.resolve(AppThemeMode.amoled, Brightness.light)
          .colorScheme
          .surface,
      AppColors.amoledSurface,
    );
    expect(
      AppTheme.resolve(AppThemeMode.system, Brightness.dark)
          .colorScheme
          .surface,
      AppColors.darkSurface,
    );
    expect(
      AppTheme.resolve(AppThemeMode.system, Brightness.light)
          .colorScheme
          .surface,
      AppColors.lightSurface,
    );
  });

  test("AppThemeMode round-trips its storage value", () {
    for (final AppThemeMode mode in AppThemeMode.values) {
      expect(AppThemeMode.fromStorageValue(mode.storageValue), mode);
    }
    expect(AppThemeMode.fromStorageValue("nonsense"), AppThemeMode.system);
    expect(AppThemeMode.fromStorageValue(null), AppThemeMode.system);
  });

  testWidgets("each theme renders without exceptions", (WidgetTester tester) async {
    for (final ThemeData theme in <ThemeData>[
      AppTheme.light,
      AppTheme.dark,
      AppTheme.amoled,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: Center(child: Text("Hello"))),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text("Hello"), findsOneWidget);
    }
  });
}
