import 'package:get/get.dart';
import '../view_model/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationsController());
  }
}
