import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  BackAppBar({
    this.actions,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: this.actions,
      toolbarHeight: 72.0,
      flexibleSpace: Image.asset(
        "assets/city.jpg",
        fit: BoxFit.cover,
        alignment: Alignment(0, -0.5),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Get.back();
              },
            );
          },
        ),
      ),
    );
  }
}
