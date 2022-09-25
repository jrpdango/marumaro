import 'package:flutter/material.dart';
import 'package:miru/widgets/user_profile_card.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: const <Widget>[
          UserProfileCard(),
        ],
      ),
    );
  }
}
