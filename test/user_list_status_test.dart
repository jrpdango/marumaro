import 'package:flutter_test/flutter_test.dart';
import 'package:miru/models/user_list_status.dart';

void main() {
  group("fromJson", () {
    test("parses every anime field", () {
      final UserListStatus status = UserListStatus.fromJson(<String, dynamic>{
        "status": "watching",
        "score": 8,
        "num_episodes_watched": 5,
        "start_date": "2020-01-02",
        "finish_date": "2020-03-04",
        "is_rewatching": true,
        "priority": 2,
        "num_times_rewatched": 3,
        "rewatch_value": 4,
        "tags": <String>["action", "drama"],
        "comments": "great",
      }, MediaKind.anime);

      expect(status.status, "watching");
      expect(status.score, 8);
      expect(status.progress, 5);
      expect(status.volumeProgress, isNull);
      expect(status.startDate, DateTime(2020, 1, 2));
      expect(status.finishDate, DateTime(2020, 3, 4));
      expect(status.isRewatching, isTrue);
      expect(status.timesRewatched, 3);
      expect(status.rewatchValue, 4);
      expect(status.priority, 2);
      expect(status.tags, "action, drama");
      expect(status.comments, "great");
    });

    test("parses every manga field", () {
      final UserListStatus status = UserListStatus.fromJson(<String, dynamic>{
        "status": "reading",
        "score": 7,
        "num_chapters_read": 12,
        "num_volumes_read": 3,
        "is_rereading": true,
        "num_times_reread": 2,
        "reread_value": 5,
      }, MediaKind.manga);

      expect(status.status, "reading");
      expect(status.progress, 12);
      expect(status.volumeProgress, 3);
      expect(status.isRewatching, isTrue);
      expect(status.timesRewatched, 2);
      expect(status.rewatchValue, 5);
    });

    test("tolerates partial and missing dates", () {
      expect(UserListStatus.parseDate("2017"), DateTime(2017, 1, 1));
      expect(UserListStatus.parseDate("2017-10"), DateTime(2017, 10, 1));
      expect(UserListStatus.parseDate("2017-10-23"), DateTime(2017, 10, 23));
      expect(UserListStatus.parseDate(null), isNull);
      expect(UserListStatus.parseDate(""), isNull);
      expect(UserListStatus.parseDate("nonsense"), isNull);
    });

    test("defaults missing fields", () {
      final UserListStatus status =
          UserListStatus.fromJson(<String, dynamic>{}, MediaKind.anime);
      expect(status.status, "");
      expect(status.score, 0);
      expect(status.progress, 0);
      expect(status.isRewatching, isFalse);
      expect(status.tags, "");
      expect(status.comments, "");
    });

    test("accepts tags as a list or a string", () {
      expect(UserListStatus.parseTags(<String>["a", "b"]), "a, b");
      expect(UserListStatus.parseTags("a b"), "a b");
      expect(UserListStatus.parseTags(<dynamic>[]), "");
      expect(UserListStatus.parseTags(null), "");
    });
  });

  group("serializeDate", () {
    test("zero-pads and handles null", () {
      expect(UserListStatus.serializeDate(DateTime(2020, 1, 2)), "2020-01-02");
      expect(UserListStatus.serializeDate(DateTime(2020, 12, 31)), "2020-12-31");
      expect(UserListStatus.serializeDate(null), isNull);
    });
  });

  group("changedPatch", () {
    const UserListStatus original = UserListStatus(
      status: "watching",
      score: 0,
      progress: 0,
    );

    test("returns nothing when unchanged", () {
      expect(original.changedPatch(MediaKind.anime, original), isEmpty);
    });

    test("maps anime keys and only includes changes", () {
      const UserListStatus updated = UserListStatus(
        status: "completed",
        score: 9,
        progress: 12,
        isRewatching: true,
        timesRewatched: 1,
        rewatchValue: 3,
        priority: 1,
        tags: "a,b",
        comments: "hi",
      );
      final Map<String, String> patch =
          updated.changedPatch(MediaKind.anime, original);

      expect(patch["status"], "completed");
      expect(patch["score"], "9");
      expect(patch["num_watched_episodes"], "12");
      expect(patch["is_rewatching"], "true");
      expect(patch["num_times_rewatched"], "1");
      expect(patch["rewatch_value"], "3");
      expect(patch["priority"], "1");
      expect(patch["tags"], "a,b");
      expect(patch["comments"], "hi");
      expect(patch.containsKey("is_rereading"), isFalse);
      expect(patch.containsKey("num_chapters_read"), isFalse);
    });

    test("maps manga keys", () {
      const UserListStatus updated = UserListStatus(
        status: "completed",
        score: 0,
        progress: 30,
        volumeProgress: 4,
        isRewatching: true,
        timesRewatched: 2,
        rewatchValue: 5,
      );
      final Map<String, String> patch =
          updated.changedPatch(MediaKind.manga, original);

      expect(patch["status"], "completed");
      expect(patch["num_chapters_read"], "30");
      expect(patch["num_volumes_read"], "4");
      expect(patch["is_rereading"], "true");
      expect(patch["num_times_reread"], "2");
      expect(patch["reread_value"], "5");
      expect(patch.containsKey("num_watched_episodes"), isFalse);
      expect(patch.containsKey("is_rewatching"), isFalse);
    });

    test("sends empty strings to clear dates", () {
      final UserListStatus original = UserListStatus(
        status: "watching",
        score: 0,
        progress: 0,
        startDate: DateTime(2020, 1, 1),
        finishDate: DateTime(2020, 2, 1),
      );
      final UserListStatus updated = UserListStatus(
        status: "watching",
        score: 0,
        progress: 0,
      );

      final Map<String, String> patch =
          updated.changedPatch(MediaKind.anime, original);

      expect(patch["start_date"], "");
      expect(patch["finish_date"], "");
      expect(patch.length, 2);
    });
  });
}
