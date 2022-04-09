import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(240, 0, 0, 0),
      appBar: AppBar(
        toolbarHeight: 72.0,
        flexibleSpace: Image.asset("assets/lofigirl.jpg", fit: BoxFit.cover),
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
            child: TextField(
              style: TextStyle(
                color: Colors.white70,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                hintText: "Search your anime list...",
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
                fillColor: Colors.blueGrey,
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
