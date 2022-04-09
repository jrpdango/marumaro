import 'package:get/get.dart';
import 'package:miru/models/mal_client.dart';

class GlobalController extends GetxController {
  final Rx<MALClient> client = MALClient().obs;
}
