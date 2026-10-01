import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/media_details/media_details.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// The navigation drawer opened from the home app bar.
///
/// Hosts the user card plus quick actions: resuming in-progress media, a
/// random planned pick, a manual sync, and account/about links.
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({
    super.key,
    required this.controller,
    required this.user,
    required this.onOpenProfile,
    required this.onLogout,
  });

  final GlobalController controller;
  final User? user;
  final VoidCallback onOpenProfile;
  final VoidCallback onLogout;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  Anime? _continueWatching;
  Manga? _continueReading;
  bool _hasPlannedAnime = false;
  bool _hasPlannedManga = false;
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_load);
    _load();
  }

  @override
  void didUpdateWidget(HomeDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_load);
      widget.controller.addListener(_load);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_load);
    super.dispose();
  }

  /// Refreshes the resume/planned candidates from the cached lists.
  Future<void> _load() async {
    final int token = ++_loadToken;
    final Anime? watching = await widget.controller.continueWatching();
    final Manga? reading = await widget.controller.continueReading();
    final Map<int, Anime> anime = await widget.controller.animeById();
    final Map<int, Manga> manga = await widget.controller.mangaById();
    if (!mounted || token != _loadToken) return;
    setState(() {
      _continueWatching = watching;
      _continueReading = reading;
      _hasPlannedAnime = anime.values.any(
        (Anime a) => a.userStatus == AnimeListStatus.planToWatch,
      );
      _hasPlannedManga = manga.values.any(
        (Manga m) => m.userStatus == MangaListStatus.planToRead,
      );
    });
  }

  void _openAnime(Anime anime) {
    Scaffold.of(context).closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AnimeDetailsPage(anime: anime)),
    );
  }

  void _openManga(Manga manga) {
    Scaffold.of(context).closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MangaDetailsPage(manga: manga)),
    );
  }

  /// Picks a random planned title, prompting for a media kind when both lists
  /// have candidates. Shows a message when there is nothing planned.
  Future<void> _pickForMe() async {
    final bool anime = _hasPlannedAnime;
    final bool manga = _hasPlannedManga;
    if (!anime && !manga) {
      _showMessage("Nothing in your Plan to Watch / Read lists yet.");
      return;
    }
    if (anime && manga) {
      final MediaKind? kind = await showModalBottomSheet<MediaKind>(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          final TextTheme text = Theme.of(context).textTheme;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.spaceLg,
                  AppTokens.spaceSm,
                  AppTokens.spaceLg,
                  AppTokens.spaceSm,
                ),
                child: Text("Pick a planned title for me", style: text.titleMedium),
              ),
              ListTile(
                leading: const Icon(Icons.movie_outlined),
                title: const Text("Get a random anime"),
                onTap: () => Navigator.of(context).pop(MediaKind.anime),
              ),
              ListTile(
                leading: const Icon(Icons.auto_stories_outlined),
                title: const Text("Get a random manga"),
                onTap: () => Navigator.of(context).pop(MediaKind.manga),
              ),
              const SizedBox(height: AppTokens.spaceSm),
            ],
          );
        },
      );
      if (kind == null) return;
      if (kind == MediaKind.anime) {
        await _openRandomAnime();
      } else {
        await _openRandomManga();
      }
      return;
    }
    if (anime) {
      await _openRandomAnime();
    } else {
      await _openRandomManga();
    }
  }

  Future<void> _openRandomAnime() async {
    final Anime? anime = await widget.controller.randomPlannedAnime();
    if (!mounted) return;
    if (anime == null) {
      _showMessage("Nothing in your Plan to Watch list yet.");
      return;
    }
    _openAnime(anime);
  }

  Future<void> _openRandomManga() async {
    final Manga? manga = await widget.controller.randomPlannedManga();
    if (!mounted) return;
    if (manga == null) {
      _showMessage("Nothing in your Plan to Read list yet.");
      return;
    }
    _openManga(manga);
  }

  Future<void> _openMalProfile() async {
    final User? user = widget.user;
    if (user == null || user.name.isEmpty) return;
    Scaffold.of(context).closeDrawer();
    final Uri uri = Uri.https('myanimelist.net', '/profile/${user.name}');
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showMessage("Could not open MyAnimeList.");
      }
    } catch (_) {
      _showMessage("Could not open MyAnimeList.");
    }
  }

  Future<void> _showAbout() async {
    String version = "";
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      version = "";
    }
    if (!mounted) return;
    showAboutDialog(
      context: context,
      applicationName: "marumaro",
      applicationVersion: version.isEmpty ? null : version,
      applicationIcon: const Icon(Icons.auto_stories, size: 40.0),
      children: const <Widget>[
        Text("A simple MyAnimeList client for viewing and updating your "
            "anime and manga lists."),
      ],
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatSyncedAt(DateTime time) {
    final Duration elapsed = DateTime.now().difference(time);
    if (elapsed.inMinutes < 1) return "just now";
    if (elapsed.inMinutes < 60) return "${elapsed.inMinutes}m ago";
    if (elapsed.inHours < 24) return "${elapsed.inHours}h ago";
    return "${elapsed.inDays}d ago";
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

  Widget _userCard(User? user, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        color: scheme.surfaceContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          onTap: () {
            Scaffold.of(context).closeDrawer();
            widget.onOpenProfile();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 20.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(300.0),
                  child: _buildAvatar(user, scheme),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.portrait, color: scheme.onSurface),
                      const SizedBox(width: AppTokens.spaceSm),
                      Expanded(
                        child: Text(
                          user?.name ?? 'Loading name...',
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _syncTile(ColorScheme scheme) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final GlobalController controller = widget.controller;
        final bool syncing = controller.syncing;
        final String subtitle;
        if (syncing) {
          subtitle = "Syncing...";
        } else if (controller.syncFailed) {
          subtitle = "Last sync failed";
        } else if (controller.lastSyncedAt != null) {
          subtitle = "Updated ${_formatSyncedAt(controller.lastSyncedAt!)}";
        } else {
          subtitle = "Not synced yet";
        }
        return ListTile(
          leading: syncing
              ? const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : Icon(
                  controller.syncFailed ? Icons.sync_problem : Icons.sync,
                  color: scheme.onSurfaceVariant,
                ),
          title: const Text("Sync now"),
          subtitle: Text(subtitle),
          enabled: !syncing,
          onTap: syncing ? null : controller.syncAll,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = widget.user;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Anime? anime = _continueWatching;
    final Manga? manga = _continueReading;
    return Drawer(
      backgroundColor: scheme.surface,
      child: Column(
        children: <Widget>[
          _userCard(user, scheme),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                if (anime != null || manga != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.spaceLg,
                      AppTokens.spaceSm,
                      AppTokens.spaceLg,
                      AppTokens.spaceXs,
                    ),
                    child: Text(
                      "Jump back in",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                if (anime != null)
                  ListTile(
                    leading: Icon(
                      Icons.play_circle_outline,
                      color: scheme.onSurfaceVariant,
                    ),
                    title: const Text("Continue watching"),
                    subtitle: Text(
                      anime.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openAnime(anime),
                  ),
                if (manga != null)
                  ListTile(
                    leading: Icon(
                      Icons.menu_book_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    title: const Text("Continue reading"),
                    subtitle: Text(
                      manga.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openManga(manga),
                  ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.casino_outlined, color: scheme.onSurfaceVariant),
                  title: const Text("Pick for me"),
                  subtitle: const Text("A random planned title"),
                  onTap: _pickForMe,
                ),
                _syncTile(scheme),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.open_in_new,
                    color: scheme.onSurfaceVariant,
                  ),
                  title: const Text("Open MyAnimeList profile"),
                  enabled: user != null && user.name.isNotEmpty,
                  onTap: _openMalProfile,
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
                  title: const Text("About marumaro"),
                  onTap: _showAbout,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextButton.icon(
              onPressed: widget.onLogout,
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
        ],
      ),
    );
  }
}
