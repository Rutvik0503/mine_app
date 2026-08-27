import 'package:get/get.dart';
import '../login/view_model/login_controller.dart';
import '../signup/view_model/signup_controller.dart';
import '../forgot_password/view_model/forgot_password_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => SignupController());
    Get.lazyPut(() => ForgotPasswordController());
  }
}
