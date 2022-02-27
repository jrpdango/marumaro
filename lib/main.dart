import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/pages/anime_details_page.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/pages/mal_web_view.dart';
import 'package:miru/pages/search.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => Loading(),
        "/home": (context) => Home(),
        "/malweb": (context) => MALWebView(),
        "/animeDetailsPage": (context) => AnimeDetailsPage(),
        "/search": (context) => Search(),
      },
    ),
  );
}
