import 'package:flutter/material.dart';
import 'package:miru/enums/app_bar_type.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarType appBarType;

  const CustomAppBar({
    Key? key,
    required this.appBarType,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      // TODO: Make customizable (e.g. have search button or not, etc)
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        flexibleSpace: Image.asset(
          'assets/city.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.45),
        ),
      ),
    );
  }
}
