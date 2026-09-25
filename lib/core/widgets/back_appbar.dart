import 'package:flutter/material.dart';
import 'package:miru/core/widgets/header_scrim.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({super.key, this.title, this.actions});

  /// An optional title shown next to the back button.
  final String? title;

  /// Optional trailing actions.
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72.0,
      title: title == null
          ? null
          : Text(title!, overflow: TextOverflow.ellipsis),
      actions: actions,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            "assets/moon.webp",
            fit: BoxFit.cover,
            alignment: Alignment(0, -0.5),
          ),
          const HeaderScrim(),
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
