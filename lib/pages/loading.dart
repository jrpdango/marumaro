import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/services/mal_client.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void setupMALConnection() async {
    MALClient client = MALClient();
    String url = client.login();
    dynamic result = await Navigator.pushNamed(context, "/malweb",
        arguments: <String, String>{"url": url});
    print("nice ${result["accessCode"]}");
    // await retrieve.getAnime();
    // Navigator.pushReplacementNamed(context, "/malweb");
  }

  @override
  void initState() {
    super.initState();
    setupMALConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitThreeBounce(
          color: Colors.black87,
        ),
      ),
    );
  }
}
