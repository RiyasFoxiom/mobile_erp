import 'package:get/get.dart';
import 'package:small_mobile_erp/controllers/sales_controller.dart';

class SalesEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SalesController());
  }
}
