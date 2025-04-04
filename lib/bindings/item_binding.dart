import 'package:get/get.dart';
import 'package:small_mobile_erp/controllers/items_controller.dart';

class ItemsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ItemsController());
  }
}
