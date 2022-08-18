import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' show SpinKitCircle;
import 'package:miru/models/mal_client.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:path_provider/path_provider.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  MALClient _client = Get.find<GlobalController>().client;

  Future<NetworkImage?> getUserImage() async {
    if (_client.userImage != null) return _client.userImage;

    try {
      _client.userImage = NetworkImage(
        (await (UserDataRequest(mode: 'Jikan').createRequest()))['data']
            ['images']['jpg']['image_url'],
      );
      return _client.userImage;
    } catch (e) {
      return _client.userImage ?? null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(240, 0, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
              color: Colors.grey[900],
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                onTap: () => Get.toNamed('/profile'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(300.0),
                        child: FutureBuilder(
                          future: getUserImage(),
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<dynamic> snapshot,
                          ) {
                            if (snapshot.hasData) {
                              return Image(
                                fit: BoxFit.cover,
                                image: snapshot.data,
                                height: 55.0,
                                width: 55.0,
                              );
                            } else
                              return Container(
                                height: 55.0,
                                width: 55.0,
                                child: SpinKitCircle(
                                  color: Colors.white,
                                ),
                              );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.portrait,
                            color: Colors.white,
                          ),
                          Text(
                            _client.username ?? 'Loading name...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('Are you sure you want to logout?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              Directory directory =
                                  await getApplicationDocumentsDirectory();
                              File("${directory.path}/miruTokens.json")
                                  .deleteSync();
                              Get.offNamed("/");
                            },
                            child: Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text('No'),
                          ),
                        ],
                      ),
                      barrierColor: Color.fromRGBO(38, 38, 38, 0.8),
                    );
                  },
                  icon: Icon(
                    Icons.logout_rounded,
                  ),
                  label: Text("Logout"),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
