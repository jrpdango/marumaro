import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/theme/app_colors.dart';
import 'package:miru/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MiruApp(controller: GlobalController()));
}

class MiruApp extends StatelessWidget {
  const MiruApp({super.key, required this.controller});

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
            home: const Loading(),
          );
        },
      ),
    );
  }
}
