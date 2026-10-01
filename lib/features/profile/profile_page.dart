import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/media_details/media_details.dart';
import 'package:marumaro/features/profile/widgets/profile_stat_card.dart';
import 'package:marumaro/features/profile/widgets/score_distribution.dart';
import 'package:marumaro/features/profile/widgets/status_breakdown.dart';

/// Shows the signed-in user's list statistics, computed from the cached lists
/// with server-provided lifetime aggregates preferred for headline numbers.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalController? _controller;
  ProfileStats? _stats;
  List<Anime> _topRated = const <Anime>[];
  int _loadToken = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = GlobalControllerScope.of(context);
      _controller!.addListener(_load);
      _load();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final int token = ++_loadToken;
    final GlobalController controller = _controller!;
    final ProfileStats stats = await controller.profileStats();
    final Map<int, Anime> anime = await controller.animeById();
    final List<Anime> topRated = anime.values
        .where((Anime a) => a.userScore > 0)
        .toList()
      ..sort((Anime a, Anime b) => b.userScore.compareTo(a.userScore));
    if (!mounted || token != _loadToken) return;
    setState(() {
      _stats = stats;
      _topRated = topRated.take(5).toList(growable: false);
    });
  }

  Widget _statRow(List<Widget> cards) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < cards.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppTokens.spaceMd),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context, User? user) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final Uri? picture = user?.picture;
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(300.0),
          child: SizedBox(
            width: 72.0,
            height: 72.0,
            child: picture == null
                ? Icon(Icons.person, color: scheme.onSurfaceVariant)
                : Image.network(
                    picture.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: scheme.onSurfaceVariant),
                  ),
          ),
        ),
        const SizedBox(width: AppTokens.spaceLg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user?.name ?? "Unknown",
                style: text.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "MyAnimeList",
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overview(BuildContext context, ProfileStats stats) {
    final String? animeMean = stats.animeMeanScore?.toStringAsFixed(2);
    final String? mangaMean = stats.mangaMeanScore?.toStringAsFixed(2);
    return Column(
      children: <Widget>[
        _statRow(<Widget>[
          ProfileStatCard(
            label: "Anime",
            value: "${stats.animeTotal}",
            icon: Icons.movie_outlined,
          ),
          ProfileStatCard(
            label: "Manga",
            value: "${stats.mangaTotal}",
            icon: Icons.auto_stories_outlined,
          ),
        ]),
        const SizedBox(height: AppTokens.spaceMd),
        _statRow(<Widget>[
          ProfileStatCard(
            label: "Episodes watched",
            value: formatCount(stats.totalEpisodes),
            icon: Icons.play_circle_outline,
          ),
          ProfileStatCard(
            label: "Chapters read",
            value: formatCount(stats.totalChapters),
            icon: Icons.menu_book_outlined,
          ),
        ]),
        const SizedBox(height: AppTokens.spaceMd),
        _statRow(<Widget>[
          ProfileStatCard(
            label: "Anime mean score",
            value: animeMean ?? "-",
          ),
          ProfileStatCard(
            label: "Manga mean score",
            value: mangaMean ?? "-",
          ),
        ]),
      ],
    );
  }

  Widget _completionSection(ProfileStats stats) {
    return _statRow(<Widget>[
      ProfileStatCard(
        label: "Anime completed",
        value: "${(stats.anime.completionRate * 100).round()}%",
        caption: "${stats.anime.completedCount} of ${stats.anime.total}",
        progress: stats.anime.completionRate,
      ),
      ProfileStatCard(
        label: "Manga completed",
        value: "${(stats.manga.completionRate * 100).round()}%",
        caption: "${stats.manga.completedCount} of ${stats.manga.total}",
        progress: stats.manga.completionRate,
      ),
    ]);
  }

  Widget _topRatedSection(BuildContext context, List<Anime> topRated) {
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < topRated.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1.0),
            ListTile(
              title: Text(
                topRated[i].title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.star_rounded, size: 16.0),
                  const SizedBox(width: AppTokens.spaceXs),
                  Text("${topRated[i].userScore}", style: text.titleSmall),
                ],
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AnimeDetailsPage(anime: topRated[i]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileStats? stats = _stats;
    return Scaffold(
      appBar: BackAppBar(title: "Profile"),
      body: stats == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              children: <Widget>[
                _header(context, _controller!.user),
                const SizedBox(height: AppTokens.spaceXl),
                SectionHeader(
                  title: "Overview",
                  child: _overview(context, stats),
                ),
                const SizedBox(height: AppTokens.spaceXl),
                SectionHeader(
                  title: "Completion",
                  child: _completionSection(stats),
                ),
                if (stats.anime.total > 0) ...<Widget>[
                  const SizedBox(height: AppTokens.spaceXl),
                  SectionHeader(
                    title: "Anime status",
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTokens.spaceMd),
                        child: StatusBreakdown(stats: stats.anime),
                      ),
                    ),
                  ),
                ],
                if (stats.manga.total > 0) ...<Widget>[
                  const SizedBox(height: AppTokens.spaceXl),
                  SectionHeader(
                    title: "Manga status",
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTokens.spaceMd),
                        child: StatusBreakdown(stats: stats.manga),
                      ),
                    ),
                  ),
                ],
                if (stats.anime.hasScores || stats.manga.hasScores) ...<Widget>[
                  const SizedBox(height: AppTokens.spaceXl),
                  SectionHeader(
                    title: "Scores",
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTokens.spaceMd),
                        child: ScoreDistribution(
                          anime: stats.anime,
                          manga: stats.manga,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_topRated.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppTokens.spaceXl),
                  SectionHeader(
                    title: "Top rated",
                    child: _topRatedSection(context, _topRated),
                  ),
                ],
                const SizedBox(height: AppTokens.spaceXl),
              ],
            ),
    );
  }
}
