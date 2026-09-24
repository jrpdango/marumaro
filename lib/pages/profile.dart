import 'package:flutter/material.dart';
import 'package:miru/widgets/back_appbar.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(),
      body: const Center(
        child: Text('Profile'),
      ),
    );
  }
}
