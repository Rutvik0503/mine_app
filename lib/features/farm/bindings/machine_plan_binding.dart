import 'package:get/get.dart';
import '../view_model/machine_plan_controller.dart';

class MachinePlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MachinePlanController());
  }
}
