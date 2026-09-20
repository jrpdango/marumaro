import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/pages/anime_details_page.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/pages/profile.dart';
import 'package:miru/pages/search.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        // TODO: maybe rename this to anime_details
        '/animeDetailsPage': (context) => AnimeDetailsPage(),
        '/search': (context) => Search(),
        '/profile': (context) => Profile(),
      },
    ),
  );
}
