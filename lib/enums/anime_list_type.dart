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

  String get apiName {
    switch (this) {
      case AnimeListType.watching:
        return 'watching';
      case AnimeListType.planToWatch:
        return 'plan_to_watch';
      case AnimeListType.completed:
        return 'completed';
      case AnimeListType.onHold:
        return 'on_hold';
      case AnimeListType.dropped:
        return 'dropped';
    }
  }
}
