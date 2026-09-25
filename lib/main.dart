import 'package:flutter/material.dart';
import 'package:tamarun/core/core.dart';
import 'package:tamarun/features/auth/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TamarunApp(controller: GlobalController()));
}

class TamarunApp extends StatelessWidget {
  const TamarunApp({super.key, required this.controller});

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
