import 'package:get/get.dart';
import '../view_model/missions_controller.dart';

class MissionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MissionsController());
  }
}
