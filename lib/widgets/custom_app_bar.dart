import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/constants.dart';
import 'package:miru/enums/app_bar_type.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarType appBarType;

  const CustomAppBar({
    Key? key,
    required this.appBarType,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  IconButton _determineLeadingIcon(BuildContext context) {
    switch (appBarType) {
      case AppBarType.drawer:
        return IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu),
        );
      case AppBarType.back:
        return IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: _determineLeadingIcon(context),
        flexibleSpace: Image.asset(
          'assets/city.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.45),
        ),
      ),
    );
  }
}
