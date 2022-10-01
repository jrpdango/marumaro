import 'package:flutter/material.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

/// This page is for user OAuth and token generation.
//
class MALWebView extends StatefulWidget {
  const MALWebView({Key? key}) : super(key: key);

  @override
  State<MALWebView> createState() => _MALWebViewState();
}

class _MALWebViewState extends State<MALWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  // TODO: Add dispose for controller

  @override
  Widget build(BuildContext context) {
    final Map? content = Get.arguments;
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) => Stack(
          children: <Widget>[
            WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: content?['url'].toString(),
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              onPageStarted: (String url) {
                // User is redirected here
                if (url.startsWith('http://localhost/oauth')) {
                  setState(() {
                    loading = true;
                  });
                  Get.back(
                    result: {
                      'accessCode': Uri.parse(url),
                    },
                  );
                }
              },
            ),
            if (loading)
              Container(
                color: Colors.black87,
              ),
          ],
        ),
      ),
    );
  }
}
