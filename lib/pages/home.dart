import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:miru/widgets/anime_list.dart';
import 'package:miru/widgets/browse.dart';
import 'package:miru/widgets/more.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/schedule.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/widgets/colored_tab_bar.dart';
import 'package:miru/widgets/list_container.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  MALClient _client = Get.find<GlobalController>().client.value;
  Map _getArgs = Get.arguments;
  Rx<int> _tabIndex = 0.obs;
  late List<ListContainer> _tabContents =
      getTabContents(_client.clientAnimeList);
  late bool _netConnected = _getArgs["connStatus"];
  late TabController _tabController;
  NetworkImage? _userImage;

  bool _hasTabBar = true;
  bool _hasSearch = true;

  late List<Widget> tabs = [
    AnimeList(
      tabController: _tabController,
      tabContents: _tabContents,
    ),
    Schedule(),
    Browse(),
    More(),
  ];

  /// Creates tabs for TabBar.
  ///
  List<Widget> createTabs() {
    List<String> tabNames = [
      "Currently Watching",
      "Plan To Watch",
      "Completed",
      "On Hold",
      "Dropped"
    ];
    List<Widget> menuTabs = [];
    for (int i = 0; i < 5; i++) {
      menuTabs.add(
        SizedBox(
          height: 30,
          child: Tab(
            child: Text(tabNames[i]),
          ),
        ),
      );
    }
    return menuTabs;
  }

  /// Initializes contents defined by [tabMap] for tabs in TabBar.
  ///
  List<ListContainer> getTabContents(Map tabMap) {
    List<String> tabNames = [
      "watching",
      "plan_to_watch",
      "completed",
      "on_hold",
      "dropped"
    ];
    List<ListContainer> tabContents = [];
    for (String tabName in tabNames) {
      tabContents.add(
        ListContainer(
          listType: tabName,
          connStatus: _netConnected,
        ),
      );
    }
    return tabContents;
  }

  Future<NetworkImage?> getUserImage() async {
    try {
      _userImage = NetworkImage(
        (await _client.getUserData(UserDataRequest(mode: 'Jikan')))['data']
            ['images']['jpg']['image_url'],
      );
      return _userImage;
    } catch (e) {
      return _userImage ?? null;
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _tabController = TabController(
      vsync: this,
      length: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
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
                                await _client.logout();
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
      ),
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: _hasTabBar ? null : 80.0,
        bottom: _hasTabBar
            ? ColoredTabBar(
                color: Colors.grey[900]!,
                tabBar: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: createTabs(),
                ),
              )
            : null,
        flexibleSpace: _hasTabBar
            ? Image.asset(
                "assets/city.jpg",
                fit: BoxFit.cover,
                alignment: Alignment(0, -0.4),
              )
            : Image.asset(
                "assets/city.jpg",
                fit: BoxFit.cover,
                alignment: Alignment(0, -0.5),
              ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        actions: _hasSearch
            ? <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                    ),
                    onPressed: () {
                      Get.toNamed("/search");
                    },
                  ),
                ),
              ]
            : <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                ),
              ],
      ),
      body: tabs[_tabIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _tabIndex.value = index;
          if (index != 0) {
            setState(() {
              _hasTabBar = false;
              _hasSearch = false;
            });
          } else {
            setState(() {
              _hasTabBar = true;
              _hasSearch = true;
            });
          }
        },
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
