import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:miru/pages/loading.dart';
import 'package:miru/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
}
