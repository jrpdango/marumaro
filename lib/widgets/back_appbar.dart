import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72.0,
      flexibleSpace: Image.asset(
        "assets/city.jpg",
        fit: BoxFit.cover,
        alignment: Alignment(0, -0.5),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
