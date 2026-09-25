import 'package:flutter/foundation.dart';
import 'package:marumaro/core/models/user_list_status.dart';

/// Normalized details rendered by `MediaDetailsView` for both anime and manga.
///
/// The anime and manga details models map themselves into this shape so the
/// details UI can be shared.
@immutable
class MediaDetailsData {
  const MediaDetailsData({
    required this.kind,
    required this.id,
    required this.title,
    required this.poster,
    required this.backdrop,
    required this.meanScore,
    required this.statusLabel,
    required this.infoRows,
    this.rank,
    this.popularity,
    this.synopsis,
    this.background,
    this.genres = const <String>[],
    this.studios = const <String>[],
    this.mediaType,
    this.englishTitle,
    this.japaneseTitle,
    this.synonyms = const <String>[],
  });

  final MediaKind kind;
  final int id;
  final String title;

  /// The list thumbnail, used as a fallback image.
  final Uri poster;

  /// A larger image used for the header backdrop.
  final Uri backdrop;

  final double meanScore;
  final String statusLabel;
  final List<MapEntry<String, String>> infoRows;
  final int? rank;
  final int? popularity;
  final String? synopsis;
  final String? background;
  final List<String> genres;
  final List<String> studios;
  final String? mediaType;
  final String? englishTitle;
  final String? japaneseTitle;
  final List<String> synonyms;
}
