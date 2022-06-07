import 'package:flutter/material.dart';

class DialogCreator {
  static AlertDialog showLogoutDialog(
      Function logoutCallback, Function closeCallback) {
    return AlertDialog(
      title: Text('You sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            logoutCallback();
          },
          child: Text('Yes'),
        ),
        TextButton(
          onPressed: () {
            closeCallback();
          },
          child: Text('No'),
        ),
      ],
    );
  }
}
