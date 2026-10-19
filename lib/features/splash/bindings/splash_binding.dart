import 'package:get/get.dart';
import '../view_model/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Eager, not lazyPut: SplashView never reads `controller` (it's static
    // UI), so a lazyPut would never actually instantiate the controller -
    // and onInit()/the auth-check-and-navigate logic would never run.
    Get.put(SplashController());
  }
}
