import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/constants.dart' as constants show limitOfListItems;
import 'package:miru/models/mal_client.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/pages/login.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/services/user_data_request.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  GlobalController? _controller;
  MALClient? _client;

  bool _needsLogin = false;

  /// Initializes the user's anime list, following pagination.
  Future<Map<String, dynamic>> _initializeAnimeList(int limit) async {
    final Map<String, dynamic> result =
        await _client!.getAnimeList(AnimeListRequest(limit: limit));
    Map<String, dynamic> newMap = Map();
    try {
      while (result["paging"]["next"] != null) {
        newMap = await _client!.getAnimeList(
          AnimeListRequest(
            limit: limit,
            url: Uri.parse(result["paging"]["next"]),
          ),
        );
        for (String item in newMap.keys) {
          if (item != "paging" && item != "status_code") {
            result[item].addAll(newMap[item]);
          }
        }
        result["paging"]["next"] = newMap["paging"]!["next"];
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  /// Restores the stored session, prompting the user to log in if needed.
  Future<void> _setupMALConnection() async {
    final bool authenticated = await _client!.auth.restoreSession();
    if (!authenticated) {
      if (mounted) setState(() => _needsLogin = true);
      return;
    }
    await _finishSetup();
  }

  /// Loads the user's list and navigates to the home page.
  Future<void> _finishSetup() async {
    final Map<String, dynamic> result =
        await _initializeAnimeList(constants.limitOfListItems);
    _controller!.setAnimeList(result);
    _client!.username =
        (await _client!.getUserData(UserDataRequest(mode: 'MAL')))['name'];

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = GlobalControllerScope.of(context);
      _client = _controller!.client;
      _setupMALConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsLogin) {
      return Login(onSignedIn: _finishSetup);
    }
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SpinKitThreeBounce(
          color: Colors.white60,
        ),
      ),
    );
  }
}
