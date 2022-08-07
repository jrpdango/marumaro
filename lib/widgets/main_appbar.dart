import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/enums/SearchType.dart';

class MainAppBar extends StatelessWidget {
  final SearchType? searchType;

  const MainAppBar({
    Key? key,
    this.searchType,
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
      actions: searchType == SearchType.local
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
