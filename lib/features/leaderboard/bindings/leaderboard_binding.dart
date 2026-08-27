import 'package:get/get.dart';
import '../view_model/leaderboard_controller.dart';

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LeaderboardController());
  }
}
