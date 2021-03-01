import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map> animeList = List();

  List<Map> testFunc() {
    Map result = Get.arguments;
    return result["animeList"];
  }

  @override
  void initState() {
    super.initState();
    animeList = this.testFunc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: ListView.builder(
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(10.0),
                child: Card(
                  child: ListTile(
                    title: Text("${animeList[index]['node']['title']}"),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
