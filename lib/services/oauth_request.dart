import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/globals.dart';
import 'package:miru/pages/login.dart';
import 'package:miru/pages/mal_web_view.dart';

class OAuthRequest {
  Future<String> send() async {
    await Get.to(() => const Login());
    debugPrint('No valid tokens. Gotta auth and get new ones.');
    String url = Globals.client.generateAuthURL();
    dynamic result = await Get.to(
      () => const MALWebView(),
      arguments: <String, String>{
        'url': url,
      },
    );
    Uri params = result['accessCode'];
    // Access code from URL parameter
    return params.queryParameters['code'] ?? '';
  }
}
