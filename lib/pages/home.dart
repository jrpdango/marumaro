import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/list_sort.dart';
import 'package:miru/models/user.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/pages/loading.dart';
import 'package:miru/pages/profile.dart';
import 'package:miru/pages/search.dart';
import 'package:miru/pages/settings.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/theme/app_colors.dart';
import 'package:miru/widgets/browse.dart';
import 'package:miru/widgets/colored_tab_bar.dart';
import 'package:miru/widgets/list_container.dart';
import 'package:miru/widgets/manga_page.dart';
import 'package:miru/widgets/media_list_pager.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  GlobalController? _controller;
  late final TabController _tabController;

  bool _syncStarted = false;
  int _tabIndex = 0;
  bool _hasTabBar = true;
  bool _hasSearch = true;

  bool get _isManga => _tabIndex == 1;

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
    if (!_syncStarted) {
      _syncStarted = true;
      _controller!.syncAll();
    }
  }

  /// Creates tabs for the list statuses.
  List<Widget> _createTabs() {
    final List<String> labels = _isManga
        ? MangaListStatus.values
            .map((MangaListStatus status) => status.label)
            .toList()
        : AnimeListStatus.values
            .map((AnimeListStatus status) => status.label)
            .toList();
    return labels
        .map(
          (String label) => SizedBox(
            height: 30,
            child: Tab(child: Text(label)),
          ),
        )
        .toList();
  }

  /// Creates the list views shown by each tab.
  List<Widget> _createTabContents() {
    return AnimeListStatus.values
        .map((AnimeListStatus status) => ListContainer(listType: status))
        .toList();
  }

  /// Applies a sort choice from the app bar menu: re-selecting the active field
  /// flips its direction, while a new field uses its default direction.
  void _handleSortSelected(ListSortField field) {
    final GlobalController controller = _controller!;
    final ListSort current = controller.listSort;
    final ListSort next = field == current.field
        ? current.toggled()
        : ListSort(field: field, descending: field.defaultDescending);
    controller.setListSort(next);
  }

  Widget _buildCurrentPage() {
    switch (_tabIndex) {
      case 0:
        return MediaListPager(
          tabController: _tabController,
          tabContents: _createTabContents(),
        );
      case 1:
        return MangaPage(tabController: _tabController);
      case 2:
        return const Browse();
      default:
        return const Settings();
    }
  }

  Future<void> _confirmLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
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
    await _controller!.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Loading()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildAvatar(User? user, ColorScheme scheme) {
    final Uri? picture = user?.picture;
    if (picture == null) {
      return SizedBox(
        height: 55.0,
        width: 55.0,
        child: Icon(Icons.person, color: scheme.onSurfaceVariant),
      );
    }
    return Image.network(
      picture.toString(),
      fit: BoxFit.cover,
      height: 55.0,
      width: 55.0,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: 55.0,
        width: 55.0,
        child: Icon(Icons.person, color: scheme.onSurfaceVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _controller!.user;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: Drawer(
        backgroundColor: scheme.surface,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                color: scheme.surfaceContainer,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
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
                          child: _buildAvatar(user, scheme),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.portrait,
                              color: scheme.onSurface,
                            ),
                            Text(
                              user?.name ?? 'Loading name...',
                              style: TextStyle(
                                color: scheme.onSurface,
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
      appBar: AppBar(
        toolbarHeight: _hasTabBar ? null : 80.0,
        title: switch (_tabIndex) {
          2 => const Text("Browse"),
          3 => const Text("Settings"),
          _ => null,
        },
        bottom: _hasTabBar
            ? ColoredTabBar(
                color: scheme.surfaceContainer,
                tabBar: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  tabs: _createTabs(),
                ),
              )
            : null,
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              "assets/moon.webp",
              fit: BoxFit.cover,
              alignment: _hasTabBar
                  ? const Alignment(0, -0.4)
                  : const Alignment(0, -0.5),
            ),
            ColoredBox(color: scheme.surface.withValues(alpha: 0.45)),
          ],
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
        actions: <Widget>[
          if (_hasTabBar)
            Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: PopupMenuButton<ListSortField>(
                icon: const Icon(Icons.sort),
                tooltip: "Sort",
                onSelected: _handleSortSelected,
                itemBuilder: (BuildContext context) {
                  final ListSort current = _controller!.listSort;
                  return ListSortField.values.map((ListSortField field) {
                    final bool active = field == current.field;
                    return PopupMenuItem<ListSortField>(
                      value: field,
                      child: Row(
                        children: <Widget>[
                          Text(field.label),
                          if (active) ...<Widget>[
                            const SizedBox(width: 8.0),
                            Icon(
                              current.descending
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              size: 16.0,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          if (_hasSearch)
            Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Search(
                      initialKind:
                          _isManga ? MediaKind.manga : MediaKind.anime,
                    ),
                  ),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 22.0),
            ),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _tabIndex = index;
            _hasTabBar = index == 0 || index == 1;
            _hasSearch = index == 0 || index == 1;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: "Manga",
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: "Browse",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
