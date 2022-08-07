import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainAppBar extends StatelessWidget {
  final bool hasSearch;

  const MainAppBar({
    Key? key,
    required this.hasSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80.0,
      flexibleSpace: Image.asset(
        "assets/city.jpg",
        fit: BoxFit.cover,
        alignment: Alignment(0, -0.5),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      actions: hasSearch
          ? <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                  ),
                  onPressed: () {
                    Get.toNamed("/searchLocal");
                  },
                ),
              ),
            ]
          : <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
              ),
            ],
    );
  }
}
