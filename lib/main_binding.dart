import 'package:get/get.dart';
import 'package:miru/utils/global_controller.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(GlobalController());
  }
}
