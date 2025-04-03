import 'package:get/get.dart';
import 'package:small_mobile_erp/controllers/report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportController());
  }
}
