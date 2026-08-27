import 'package:get/get.dart';
import '../view_model/machine_controller.dart';

class MachineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MachineController());
  }
}
