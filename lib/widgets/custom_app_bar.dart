import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/enums/app_bar_type.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarType appBarType;
  final bool hasBackground;

  const CustomAppBar({
    Key? key,
    required this.appBarType,
    this.hasBackground = true,
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

  Widget? get _flexibleSpace {
    if (hasBackground) {
      return Image.asset(
        'assets/city.jpg',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.45),
      );
    }
    return null;
  }

  Color? get _backgroundColor {
    if (!hasBackground) {
      return Colors.transparent;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: SizedBox(
        height: preferredSize.height,
        child: AppBar(
          primary: false,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          leading: _determineLeadingIcon(context),
          flexibleSpace: _flexibleSpace,
          backgroundColor: _backgroundColor,
        ),
      ),
    );
  }
}
