import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton.icon(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Are you sure you want to logout?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Directory directory =
                            await getApplicationDocumentsDirectory();
                        File("${directory.path}/miruTokens.json").deleteSync();
                        Get.offNamed("/");
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
                barrierColor: const Color.fromRGBO(38, 38, 38, 0.8),
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
            label: const Text("Logout"),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
