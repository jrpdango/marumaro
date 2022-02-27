import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

/// This page is for user OAuth and token generation.
//
class MALWebView extends StatefulWidget {
  @override
  _MALWebViewState createState() => _MALWebViewState();
}

class _MALWebViewState extends State<MALWebView> {
  final Completer<InAppWebViewController> _controller =
      Completer<InAppWebViewController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map content = Get.arguments;
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) => InAppWebView(
          initialUrlRequest: URLRequest(url: content["url"]),
          onWebViewCreated: (InAppWebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onLoadStart: (InAppWebViewController _controller, Uri? url) {
            // User is redirected here
            if (url!.toString().startsWith("http://localhost/oauth")) {
              Get.back(result: {"accessCode": url});
            }
          },
        ),
      ),
    );
  }
}
