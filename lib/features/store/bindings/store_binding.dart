import 'package:get/get.dart';
import '../view_model/store_controller.dart';

class StoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoreController());
  }
}
