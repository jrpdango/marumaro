import 'package:tamarun/core/models/enums.dart';

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
    this.inList = true,
    this.meanScore,
    this.rank,
    this.mediaType,
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

  /// Whether this manga is on the user's list. False for browse results.
  final bool inList;

  /// The community mean score, when supplied by browse endpoints.
  final double? meanScore;

  /// The ranking position, when supplied by ranking endpoints.
  final int? rank;

  /// The media type (e.g. `manga`, `novel`), when supplied by browse endpoints.
  final String? mediaType;

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

  /// Parses a manga returned by the browse endpoints (ranking), which has no
  /// `list_status` and therefore is not on the user's list.
  factory Manga.fromNodeJson(Map<String, dynamic> json) {
    final Map<String, dynamic> node =
        (json["node"] as Map?)?.cast<String, dynamic>() ?? json;
    final Map<String, dynamic>? ranking =
        (json["ranking"] as Map?)?.cast<String, dynamic>();
    final String? picture = (node["main_picture"] as Map?)?["medium"] as String?;
    return Manga(
      id: node["id"] as int,
      title: (node["title"] as String?) ?? "",
      picture: Uri.parse(picture ?? ""),
      totalChapters: (node["num_chapters"] as int?) ?? 0,
      totalVolumes: (node["num_volumes"] as int?) ?? 0,
      publishingStatus:
          MangaPublishingStatus.fromApiValue(node["status"] as String?),
      userStatus: MangaListStatus.planToRead,
      userChaptersRead: 0,
      userVolumesRead: 0,
      userScore: 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      inList: false,
      meanScore: (node["mean"] as num?)?.toDouble(),
      rank: ranking?["rank"] as int?,
      mediaType: node["media_type"] as String?,
    );
  }

  Manga copyWith({
    MangaListStatus? userStatus,
    int? userChaptersRead,
    int? userVolumesRead,
    int? userScore,
    DateTime? updatedAt,
    bool? inList,
    double? meanScore,
    int? rank,
    String? mediaType,
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
      inList: inList ?? this.inList,
      meanScore: meanScore ?? this.meanScore,
      rank: rank ?? this.rank,
      mediaType: mediaType ?? this.mediaType,
    );
  }
}
