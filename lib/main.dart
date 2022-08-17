// Packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Pages
import 'package:miru/pages/anime_details_page.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/pages/login.dart';
import 'package:miru/pages/mal_web_view.dart';
import 'package:miru/pages/profile.dart';
import 'package:miru/pages/search_local_anime.dart';
import 'package:miru/pages/search_online_anime.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
    await Future.delayed(const Duration(seconds: 1));
    SystemChrome.restoreSystemUIOverlays();
  });

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/malweb': (context) => MALWebView(),
        '/animeDetailsPage': (context) => AnimeDetailsPage(),
        '/searchLocalAnime': (context) => SearchLocalAnime(),
        '/searchOnlineAnime': (context) => SearchOnlineAnime(),
        '/login': (context) => Login(),
        '/profile': (context) => Profile(),
      },
    ),
  );
}
