import 'package:flutter/material.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/services/global_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MiruApp(controller: GlobalController()));
}

class MiruApp extends StatelessWidget {
  const MiruApp({Key? key, required this.controller}) : super(key: key);

  final GlobalController controller;

  @override
  Widget build(BuildContext context) {
    return GlobalControllerScope(
      controller: controller,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Loading(),
      ),
    );
  }
}
