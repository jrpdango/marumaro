import 'package:flutter_test/flutter_test.dart';
import 'package:miru/core/models/enums.dart';
import 'package:miru/core/models/user_list_status.dart';
import 'package:miru/features/media_details/edit_list_draft.dart';

EditListDraft _draft({
  String status = "watching",
  int score = 0,
  String progressText = "0",
  String volumesText = "0",
  DateTime? startDate,
  DateTime? finishDate,
  bool isRewatching = false,
  String timesText = "0",
  int rewatchValue = 0,
  int priority = 0,
  String tags = "",
  String comments = "",
}) {
  return EditListDraft(
    status: status,
    score: score,
    progressText: progressText,
    volumesText: volumesText,
    startDate: startDate,
    finishDate: finishDate,
    isRewatching: isRewatching,
    timesText: timesText,
    rewatchValue: rewatchValue,
    priority: priority,
    tags: tags,
    comments: comments,
  );
}

void main() {
  group("toStatus", () {
    test("parses numeric text fields", () {
      final UserListStatus status = _draft(
        progressText: "12",
        volumesText: "3",
        timesText: "2",
      ).toStatus(MediaKind.manga);

      expect(status.progress, 12);
      expect(status.volumeProgress, 3);
      expect(status.timesRewatched, 2);
    });

    test("drops volumes for anime", () {
      final UserListStatus status =
          _draft(volumesText: "3").toStatus(MediaKind.anime);
      expect(status.volumeProgress, isNull);
    });

    test("treats invalid numbers as zero", () {
      final UserListStatus status = _draft(
        progressText: "",
        timesText: "nope",
      ).toStatus(MediaKind.anime);

      expect(status.progress, 0);
      expect(status.timesRewatched, 0);
    });
  });

  group("patch", () {
    const UserListStatus baseline = UserListStatus(
      status: "watching",
      score: 7,
      progress: 3,
    );

    test("is empty when nothing changed", () {
      final EditListDraft draft =
          _draft(status: "watching", score: 7, progressText: "3");

      expect(draft.patch(MediaKind.anime, baseline), isEmpty);
      expect(draft.isDirty(MediaKind.anime, baseline), isFalse);
    });

    test("contains only the changed fields", () {
      final Map<String, String> patch = _draft(
        status: "completed",
        score: 9,
        progressText: "5",
      ).patch(MediaKind.anime, baseline);

      expect(patch["status"], "completed");
      expect(patch["score"], "9");
      expect(patch["num_watched_episodes"], "5");
      expect(patch.containsKey("tags"), isFalse);
    });

    test("includes volumes when changed for manga", () {
      const UserListStatus mangaBaseline = UserListStatus(
        status: "reading",
        score: 0,
        progress: 1,
        volumeProgress: 1,
      );
      final Map<String, String> patch = _draft(
        status: "reading",
        progressText: "1",
        volumesText: "2",
      ).patch(MediaKind.manga, mangaBaseline);

      expect(patch["num_volumes_read"], "2");
    });

    test("detects a score-only change", () {
      expect(
        _draft(status: "watching", score: 8, progressText: "3")
            .isDirty(MediaKind.anime, baseline),
        isTrue,
      );
    });
  });

  group("validatedStatus", () {
    test("keeps valid values", () {
      expect(
        EditListDraft.validatedStatus("watching", MediaKind.anime),
        "watching",
      );
      expect(
        EditListDraft.validatedStatus("reading", MediaKind.manga),
        "reading",
      );
    });

    test("falls back to the in-progress status", () {
      expect(
        EditListDraft.validatedStatus("bogus", MediaKind.anime),
        AnimeListStatus.watching.apiValue,
      );
      expect(
        EditListDraft.validatedStatus("bogus", MediaKind.manga),
        MangaListStatus.reading.apiValue,
      );
    });
  });

  group("statusOptions", () {
    test("lists the statuses for each kind", () {
      expect(
        EditListDraft.statusOptions(MediaKind.anime).map((e) => e.key),
        AnimeListStatus.values.map((s) => s.apiValue),
      );
      expect(
        EditListDraft.statusOptions(MediaKind.manga).map((e) => e.key),
        MangaListStatus.values.map((s) => s.apiValue),
      );
    });
  });

  group("MediaKindLabels", () {
    test("returns anime labels", () {
      const MediaKindLabels labels = MediaKindLabels(MediaKind.anime);
      expect(labels.progressSection, "Episodes");
      expect(labels.progressField, "Episodes Watched");
      expect(labels.rewatchSection, "Rewatch");
      expect(labels.rewatching, "Rewatching");
      expect(labels.timesField, "Times Rewatched");
      expect(labels.rewatchValueField, "Rewatch Value");
    });

    test("returns manga labels", () {
      const MediaKindLabels labels = MediaKindLabels(MediaKind.manga);
      expect(labels.progressSection, "Chapters");
      expect(labels.progressField, "Chapters Read");
      expect(labels.rewatchSection, "Reread");
      expect(labels.rewatching, "Rereading");
      expect(labels.timesField, "Times Reread");
      expect(labels.rewatchValueField, "Reread Value");
    });
  });
}
