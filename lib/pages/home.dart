import 'package:flutter/material.dart';
import 'package:miru/widgets/anime_list.dart';
import 'package:miru/widgets/base_app_bar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: Add custom drawer
      drawer: const Drawer(
        child: Text('This is the drawer'),
      ),
      appBar: const BaseAppBar(),
      body: const AnimeList(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              backgroundColor: Colors.black87,
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              backgroundColor: Colors.black87,
              label: "Schedule"),
          BottomNavigationBarItem(
              icon: Icon(Icons.compass_calibration_rounded),
              backgroundColor: Colors.black87,
              label: "Browse"),
          BottomNavigationBarItem(
              icon: Icon(Icons.more),
              backgroundColor: Colors.black87,
              label: "More"),
        ],
      ),
    );
  }
}
