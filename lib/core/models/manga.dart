import 'package:miru/core/models/enums.dart';

/// A manga entry from the user's list.
class Manga {
  const Manga({
    required this.id,
    required this.title,
    required this.picture,
    required this.totalChapters,
    required this.totalVolumes,
    required this.publishingStatus,
    required this.userStatus,
    required this.userChaptersRead,
    required this.userVolumesRead,
    required this.userScore,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final Uri picture;
  final int totalChapters;
  final int totalVolumes;
  final MangaPublishingStatus? publishingStatus;
  final MangaListStatus userStatus;
  final int userChaptersRead;
  final int userVolumesRead;
  final int userScore;
  final DateTime updatedAt;

  factory Manga.fromListStatusJson(Map<String, dynamic> json) {
    final Map<String, dynamic> node =
        (json["node"] as Map).cast<String, dynamic>();
    final Map<String, dynamic> listStatus =
        (json["list_status"] as Map).cast<String, dynamic>();
    final String? picture = (node["main_picture"] as Map?)?["medium"] as String?;
    return Manga(
      id: node["id"] as int,
      title: (node["title"] as String?) ?? "",
      picture: Uri.parse(picture ?? ""),
      totalChapters: (node["num_chapters"] as int?) ?? 0,
      totalVolumes: (node["num_volumes"] as int?) ?? 0,
      publishingStatus:
          MangaPublishingStatus.fromApiValue(node["status"] as String?),
      userStatus: MangaListStatus.fromApiValue(listStatus["status"] as String?),
      userChaptersRead: (listStatus["num_chapters_read"] as int?) ?? 0,
      userVolumesRead: (listStatus["num_volumes_read"] as int?) ?? 0,
      userScore: (listStatus["score"] as int?) ?? 0,
      updatedAt: DateTime.tryParse(
            (listStatus["updated_at"] as String?) ?? "",
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Manga copyWith({
    MangaListStatus? userStatus,
    int? userChaptersRead,
    int? userVolumesRead,
    int? userScore,
    DateTime? updatedAt,
  }) {
    return Manga(
      id: id,
      title: title,
      picture: picture,
      totalChapters: totalChapters,
      totalVolumes: totalVolumes,
      publishingStatus: publishingStatus,
      userStatus: userStatus ?? this.userStatus,
      userChaptersRead: userChaptersRead ?? this.userChaptersRead,
      userVolumesRead: userVolumesRead ?? this.userVolumesRead,
      userScore: userScore ?? this.userScore,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
