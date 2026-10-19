import 'package:get/get.dart';
import '../view_model/spin_controller.dart';

class SpinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SpinController());
  }
}
