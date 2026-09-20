import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

/// This page is for user OAuth and token generation.
//
class MALWebView extends StatefulWidget {
  @override
  _MALWebViewState createState() => _MALWebViewState();
}

class _MALWebViewState extends State<MALWebView> {
  late final WebViewController _controller;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final Map? content = Get.arguments;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // User is redirected here
            if (url.startsWith("http://localhost/oauth")) {
              setState(() {
                loading = true;
              });
              Get.back(
                result: {
                  "accessCode": Uri.parse(url),
                },
              );
            }
          },
        ),
      );
    final String? url = content?["url"]?.toString();
    if (url != null && url.isNotEmpty) {
      _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (loading)
            Container(
              color: Colors.black87,
            ),
        ],
      ),
    );
  }
}
