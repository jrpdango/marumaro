import 'package:flutter/foundation.dart';

enum AnimeListType {
  watching,
  planToWatch,
  completed,
  onHold,
  dropped,
}

extension AnimeListTypeExtension on AnimeListType {
  String get name => describeEnum(this);
  String get displayName {
    switch (this) {
      case AnimeListType.watching:
        return 'Watching';
      case AnimeListType.planToWatch:
        return 'Plan To Watch';
      case AnimeListType.completed:
        return 'Completed';
      case AnimeListType.onHold:
        return 'On Hold';
      case AnimeListType.dropped:
        return 'Dropped';
    }
  }
}
