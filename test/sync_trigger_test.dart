import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:miru/core/core.dart';

class _FakeStore extends LocalStore {
  _FakeStore();

  @override
  Future<void> replaceAnimeStatus(
    AnimeListStatus status,
    List<Anime> items,
  ) async {}

  @override
  Future<void> replaceMangaStatus(
    MangaListStatus status,
    List<Manga> items,
  ) async {}
}

class _EmptyRepository extends MalRepository {
  _EmptyRepository()
      : super(
          api: MalApiClient(
            httpClient: http.Client(),
            accessTokenProvider: () => null,
          ),
        );

  @override
  Future<PageResult<Anime>> fetchAnimeListPage({
    required int offset,
    int limit = MalRepository.pageSize,
    AnimeListStatus? status,
  }) async {
    return const PageResult<Anime>(items: <Anime>[], hasMore: false);
  }
}

class _SyncProbe extends StatefulWidget {
  const _SyncProbe();

  @override
  State<_SyncProbe> createState() => _SyncProbeState();
}

class _SyncProbeState extends State<_SyncProbe> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    GlobalControllerScope.of(context).syncAnime();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GlobalControllerScope.of(context),
      builder: (BuildContext context, Widget? child) => const SizedBox(),
    );
  }
}

void main() {
  testWidgets('starting a sync during didChangeDependencies is safe',
      (WidgetTester tester) async {
    final GlobalController controller = GlobalController(
      store: _FakeStore(),
      repository: _EmptyRepository(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      GlobalControllerScope(
        controller: controller,
        child: const MaterialApp(home: _SyncProbe()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(controller.animeSynced, isTrue);
  });
}
