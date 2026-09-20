import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/mal_client.dart';

/// Application-wide state: the MAL client and the user's anime lists.
class GlobalController extends ChangeNotifier {
  final MALClient client = MALClient();
  final List<Anime> globalAnimeList = <Anime>[];
  final Map<String, List<Anime>> lists = <String, List<Anime>>{
    "watching": <Anime>[],
    "plan_to_watch": <Anime>[],
    "completed": <Anime>[],
    "on_hold": <Anime>[],
    "dropped": <Anime>[],
  };

  /// Replaces the current lists with the given [result] of status-keyed lists.
  void setAnimeList(Map<String, dynamic> result) {
    globalAnimeList.clear();
    for (final List<Anime> list in lists.values) {
      list.clear();
    }
    for (final MapEntry<String, dynamic> entry in result.entries) {
      if (entry.key == "paging" || entry.key == "status_code") continue;
      final List<Anime> list = (entry.value as List).cast<Anime>();
      globalAnimeList.addAll(list);
      lists[entry.key]?.addAll(list);
    }
    notifyListeners();
  }

  /// Moves [anime] between status buckets after a list update.
  void moveAnime(Anime anime, String fromStatus, String toStatus) {
    if (fromStatus != toStatus) {
      lists[fromStatus]?.remove(anime);
      lists.putIfAbsent(toStatus, () => <Anime>[]).insert(0, anime);
    }
    notifyListeners();
  }
}

/// Exposes a [GlobalController] to the widget tree.
class GlobalControllerScope extends InheritedNotifier<GlobalController> {
  const GlobalControllerScope({
    super.key,
    required GlobalController controller,
    required super.child,
  }) : super(notifier: controller);

  static GlobalController of(BuildContext context) {
    final GlobalControllerScope? scope =
        context.dependOnInheritedWidgetOfExactType<GlobalControllerScope>();
    assert(scope != null, "No GlobalControllerScope found in context");
    return scope!.notifier!;
  }
}
