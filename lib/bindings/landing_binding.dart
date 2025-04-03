import 'package:get/get.dart';
import 'package:small_mobile_erp/controllers/landing_controller.dart';

class LandingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LandingController());
  }
}
