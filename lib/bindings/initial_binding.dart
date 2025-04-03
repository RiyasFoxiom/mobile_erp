import 'package:get/get.dart';
import 'package:small_mobile_erp/bindings/home_binding.dart';
import 'package:small_mobile_erp/bindings/landing_binding.dart';
import 'package:small_mobile_erp/bindings/report_binding.dart';
import 'package:small_mobile_erp/bindings/sales_entry_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    LandingBinding().dependencies();
    HomeBinding().dependencies();
    SalesEntryBinding().dependencies();
    ReportBinding().dependencies();
  }
}
