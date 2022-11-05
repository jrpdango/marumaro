import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:miru/globals.dart';
import 'package:miru/objectbox.g.dart';

import 'package:miru/pages/loading.dart';
import 'package:miru/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox and assign store globally
  Globals.store = await openStore();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.bottom,
    ],
  );
  SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
    await Future.delayed(const Duration(seconds: 1));
    SystemChrome.restoreSystemUIOverlays();
  });

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Loading(),
      theme: themeData,
    ),
  );

  // store.close();
}
