import 'package:tamarun/core/models/enums.dart';
import 'package:tamarun/core/models/user_list_status.dart';

/// The values gathered by the edit form, decoupled from the widgets and text
/// controllers so the status/patch mapping can be unit-tested on its own.
class EditListDraft {
  const EditListDraft({
    required this.status,
    required this.score,
    required this.progressText,
    required this.volumesText,
    required this.startDate,
    required this.finishDate,
    required this.isRewatching,
    required this.timesText,
    required this.rewatchValue,
    required this.priority,
    required this.tags,
    required this.comments,
  });

  final String status;
  final int score;
  final String progressText;
  final String volumesText;
  final DateTime? startDate;
  final DateTime? finishDate;
  final bool isRewatching;
  final String timesText;
  final int rewatchValue;
  final int priority;
  final String tags;
  final String comments;

  /// The resulting status. Anime drops the volume field; manga keeps it.
  UserListStatus toStatus(MediaKind kind) {
    return UserListStatus(
      status: status,
      score: score,
      progress: int.tryParse(progressText) ?? 0,
      volumeProgress:
          kind == MediaKind.manga ? (int.tryParse(volumesText) ?? 0) : null,
      startDate: startDate,
      finishDate: finishDate,
      isRewatching: isRewatching,
      timesRewatched: int.tryParse(timesText) ?? 0,
      rewatchValue: rewatchValue,
      priority: priority,
      tags: tags,
      comments: comments,
    );
  }

  /// The fields that changed relative to [baseline].
  Map<String, String> patch(MediaKind kind, UserListStatus baseline) =>
      toStatus(kind).changedPatch(kind, baseline);

  bool isDirty(MediaKind kind, UserListStatus baseline) =>
      patch(kind, baseline).isNotEmpty;

  /// The valid status options for [kind], as `(apiValue, label)` pairs.
  static List<MapEntry<String, String>> statusOptions(MediaKind kind) {
    return kind == MediaKind.anime
        ? AnimeListStatus.values
            .map((AnimeListStatus s) => MapEntry(s.apiValue, s.label))
            .toList()
        : MangaListStatus.values
            .map((MangaListStatus s) => MapEntry(s.apiValue, s.label))
            .toList();
  }

  /// Falls back to the canonical "in progress" status when [value] is not a
  /// valid option for [kind].
  static String validatedStatus(String value, MediaKind kind) {
    final bool exists = kind == MediaKind.anime
        ? AnimeListStatus.values
            .any((AnimeListStatus s) => s.apiValue == value)
        : MangaListStatus.values
            .any((MangaListStatus s) => s.apiValue == value);
    if (exists) return value;
    return kind == MediaKind.anime
        ? AnimeListStatus.watching.apiValue
        : MangaListStatus.reading.apiValue;
  }
}

/// Human-readable labels for the fields that differ between anime and manga.
class MediaKindLabels {
  const MediaKindLabels(this.kind);

  final MediaKind kind;

  bool get isAnime => kind == MediaKind.anime;

  String get progressSection => isAnime ? "Episodes" : "Chapters";
  String get progressField => isAnime ? "Episodes Watched" : "Chapters Read";
  String get volumesField => "Volumes Read";
  String get rewatchSection => isAnime ? "Rewatch" : "Reread";
  String get rewatching => isAnime ? "Rewatching" : "Rereading";
  String get timesField => isAnime ? "Times Rewatched" : "Times Reread";
  String get rewatchValueField => isAnime ? "Rewatch Value" : "Reread Value";
}
