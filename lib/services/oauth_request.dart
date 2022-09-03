import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:miru/globals.dart';

class OAuthRequest {
  Future<String> send() async {
    await Get.toNamed("/login");
    debugPrint("No valid tokens. Gotta auth and get new ones.");
    String url = Globals.client.generateAuthURL();
    dynamic result = await Get.toNamed(
      "/mal_web_view",
      arguments: <String, String>{
        "url": url,
      },
    );
    Uri params = result["accessCode"];
    // Access code from URL parameter
    return params.queryParameters["code"] ?? '';
  }
}
