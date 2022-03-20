import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/widgets/ColoredTabBar.dart';
import 'package:miru/widgets/ListContainer.dart';

class Home extends StatefulWidget {
  final Map? animeMap;
  final MALClient? client;

  const Home({Key? key, this.animeMap, this.client}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map _getArgs = Get.arguments;
  late Map _animeMap = widget.animeMap!;
  late List<ListContainer> _tabContents = getTabContents(_animeMap);
  late bool _netConnected = _getArgs["connStatus"];

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
          animeMapCallback: (val) {
            setState(() => _animeMap = val);
            refreshListLocal();
          },
          animeList: tabMap[tabName] ?? [],
          animeListCallback: (val, oldStatus, index) {
            setState(
              () {
                _animeMap[val["list_status"]["status"]].add(val);
                _animeMap[oldStatus].removeAt(index);
              },
            );
          },
          client: widget.client!,
          listType: tabName,
          connStatus: _netConnected,
        ),
      );
    }
    return tabContents;
  }

  /// Used to update entire list contents when a tab is refreshed.
  ///
  Future<void> refreshListLocal() async {
    // bool checkConn = await DataConnectionChecker().hasConnection;
    setState(
      () {
        // _netConnected = checkConn;
        _tabContents = getTabContents(_animeMap);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: Drawer(
          child: Container(
            child: Text("Heyo"),
          ),
        ),
        backgroundColor: Colors.black,
        appBar: AppBar(
          bottom: ColoredTabBar(
            color: Colors.grey[900]!,
            tabBar: TabBar(
              isScrollable: true,
              tabs: createTabs(),
            ),
          ),
          flexibleSpace: Image.asset("assets/lofigirl.jpg", fit: BoxFit.cover),
          leading: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Get.toNamed("/search");
                },
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: _tabContents,
        ),
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
                icon: Icon(Icons.person),
                backgroundColor: Colors.black87,
                label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.more),
                backgroundColor: Colors.black87,
                label: "More"),
          ],
        ),
      ),
    );
  }
}
