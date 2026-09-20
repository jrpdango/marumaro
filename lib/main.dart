import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/services/global_controller.dart';

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(surface: Colors.black),
          scaffoldBackgroundColor: Colors.black,
          canvasColor: Colors.black,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(
                backgroundColor: Colors.black,
              ),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        themeMode: ThemeMode.dark,
        home: const Loading(),
      ),
    );
  }
}
