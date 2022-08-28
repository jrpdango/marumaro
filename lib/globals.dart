import 'package:miru/models/anime.dart';
import 'package:miru/utils/mal_client.dart';

import 'package:get/get.dart';

class Globals {
  static final MALClient client = MALClient();
  static RxList<Anime> globalAnimeList = <Anime>[].obs;
}
