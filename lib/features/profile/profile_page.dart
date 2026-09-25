import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
