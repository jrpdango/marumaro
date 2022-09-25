import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListContainer extends StatefulWidget {
  const ListContainer({Key? key}) : super(key: key);

  @override
  State<ListContainer> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ListContainer> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: Obx(
          () => ListView.builder(
            itemBuilder: ((context, index) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              );
            }),
          ),
        ),
        onRefresh: () async {
          return await null;
        });
  }
}
