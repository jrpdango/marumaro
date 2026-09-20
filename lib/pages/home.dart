import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/user.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/pages/profile.dart';
import 'package:miru/pages/search.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/anime_list.dart';
import 'package:miru/widgets/browse.dart';
import 'package:miru/widgets/colored_tab_bar.dart';
import 'package:miru/widgets/list_container.dart';
import 'package:miru/widgets/more.dart';
import 'package:miru/widgets/schedule.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  GlobalController? _controller;
  late final TabController _tabController;

  int _tabIndex = 0;
  bool _hasTabBar = true;
  bool _hasSearch = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _tabController =
        TabController(vsync: this, length: AnimeListStatus.values.length);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
  }

  /// Creates tabs for the list statuses.
  List<Widget> _createTabs() {
    return AnimeListStatus.values
        .map(
          (AnimeListStatus status) => SizedBox(
            height: 30,
            child: Tab(child: Text(status.label)),
          ),
        )
        .toList();
  }

  /// Creates the list views shown by each tab.
  List<ListContainer> _createTabContents() {
    return AnimeListStatus.values
        .map((AnimeListStatus status) => ListContainer(listType: status))
        .toList();
  }

  Widget _buildCurrentPage() {
    switch (_tabIndex) {
      case 0:
        return AnimeList(
          tabController: _tabController,
          tabContents: _createTabContents(),
        );
      case 1:
        return const Schedule();
      case 2:
        return const Browse();
      default:
        return const More();
    }
  }

  Future<void> _confirmLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color.fromRGBO(38, 38, 38, 0.8),
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _controller!.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Loading()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildAvatar(User? user) {
    final Uri? picture = user?.picture;
    if (picture == null) {
      return const SizedBox(
        height: 55.0,
        width: 55.0,
        child: Icon(Icons.person, color: Colors.white),
      );
    }
    return Image.network(
      picture.toString(),
      fit: BoxFit.cover,
      height: 55.0,
      width: 55.0,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        height: 55.0,
        width: 55.0,
        child: Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _controller!.user;
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(240, 0, 0, 0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                color: Colors.grey[900],
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(7.0)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Profile()),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(300.0),
                          child: _buildAvatar(user),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.portrait,
                              color: Colors.white,
                            ),
                            Text(
                              user?.name ?? 'Loading name...',
                              style: const TextStyle(
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
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text("Logout"),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                  tabs: _createTabs(),
                ),
              )
            : null,
        flexibleSpace: Image.asset(
          "assets/city.jpg",
          fit: BoxFit.cover,
          alignment:
              _hasTabBar ? const Alignment(0, -0.4) : const Alignment(0, -0.5),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
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
                    icon: const Icon(Icons.search),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Search()),
                    ),
                  ),
                ),
              ]
            : <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 22.0),
                ),
              ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
            _hasTabBar = index == 0;
            _hasSearch = index == 0;
          });
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
