import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: 72.0,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            "assets/moon.webp",
            fit: BoxFit.cover,
            alignment: Alignment(0, -0.5),
          ),
          ColoredBox(color: scheme.surface.withValues(alpha: 0.45)),
        ],
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
