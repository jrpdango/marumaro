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
    return Column(
      children: <Widget>[
        Text("This is the search page."),
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Go back to Home"),
        ),
      ],
    );
  }
}
