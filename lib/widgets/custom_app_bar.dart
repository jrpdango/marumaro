import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/enums/app_bar_type.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarType appBarType;
  final bool hasBackground;
  static const double fixedHeight = 60.0;

  const CustomAppBar({
    Key? key,
    required this.appBarType,
    this.hasBackground = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(fixedHeight);

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

  Widget? get flexibleSpace {
    if (hasBackground) {
      return Image.asset(
        'assets/city.jpg',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.45),
      );
    }
    return null;
  }

  Color? get backgroundColor {
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
        height: fixedHeight,
        child: AppBar(
          primary: false,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          leading: _determineLeadingIcon(context),
          flexibleSpace: flexibleSpace,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
