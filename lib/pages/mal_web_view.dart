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
    Map content = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) => InAppWebView(
          initialUrl: content["url"],
          onWebViewCreated: (InAppWebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onLoadStart: (InAppWebViewController _controller, String url) {
            // User is redirected here
            if (url.startsWith("http://localhost/oauth")) {
              Get.back(result: {"accessCode": url});
            }
          },
        ),
      ),
    );
  }
}
