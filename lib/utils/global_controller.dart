import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/utils/mal_client.dart';

class GlobalController extends GetxController {
  final MALClient client = MALClient();
  RxList<Anime> globalAnimeList = <Anime>[].obs;
}
