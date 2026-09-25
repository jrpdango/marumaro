import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/auth/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MarumaroApp(controller: GlobalController()));
}

class MarumaroApp extends StatelessWidget {
  const MarumaroApp({super.key, required this.controller});

  final GlobalController controller;

  @override
  Widget build(BuildContext context) {
    return GlobalControllerScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          final AppThemeMode mode = controller.themeMode;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme:
                mode == AppThemeMode.amoled ? AppTheme.amoled : AppTheme.dark,
            themeMode: switch (mode) {
              AppThemeMode.light => ThemeMode.light,
              AppThemeMode.dark => ThemeMode.dark,
              AppThemeMode.amoled => ThemeMode.dark,
              AppThemeMode.system => ThemeMode.system,
            },
            themeAnimationDuration: AppTokens.medium,
            home: const LoadingPage(),
          );
        },
      ),
    );
  }
}
