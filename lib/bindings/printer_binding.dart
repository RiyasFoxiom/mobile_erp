import 'package:get/get.dart';
import 'package:small_mobile_erp/controllers/printer_controller.dart';

class PrinterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrinterController());
  }
}
