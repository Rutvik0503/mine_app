import 'package:get/get.dart';
import '../view_model/achievements_controller.dart';

class AchievementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AchievementsController());
  }
}
