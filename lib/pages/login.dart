import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(15.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Hello, and welcome to miru! To get started, tap the button below to log in your MyAnimeList account.",
                style: TextStyle(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.login_rounded),
          label: Text("Login to MyAnimeList"),
        ),
      ],
    );
  }
}
