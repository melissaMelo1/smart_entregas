import 'package:get/get.dart';
import 'package:smart_entregas/views/home/commercial_page.dart';
import 'package:smart_entregas/views/home/logistic_page.dart';
import 'package:smart_entregas/views/home/delivery_page.dart';
import 'package:smart_entregas/views/login/controller/auth_controller.dart';
import 'package:smart_entregas/views/login/login_page.dart';
import 'package:smart_entregas/views/login/otp_page.dart';
import 'package:smart_entregas/views/login/phone_page.dart';
import 'package:smart_entregas/views/register/register_page.dart';
import 'package:smart_entregas/views/delivery/delivery_details_page.dart';
import 'package:smart_entregas/views/delivery/register_delivery_page.dart';

class AppPages {
  static const LOGIN = '/login';
  static const PHONE = '/phone';
  static const OTP = '/otp';
  static const COMMERCIAL = '/commercial';
  static const LOGISTIC = '/logistic';
  static const DELIVERY = '/delivery';
  static const REGISTER = '/register';
  static const DELIVERY_DETAILS = '/delivery_details';
  static const REGISTER_DELIVERY = '/register_delivery';

  static final routes = [
    GetPage(name: LOGIN, page: () => LoginPage()),
    GetPage(
      name: PHONE,
      page: () => PhonePage(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(name: OTP, page: () => OtpPage()),
    GetPage(name: COMMERCIAL, page: () => const CommercialPage()),
    GetPage(name: REGISTER, page: () => const RegisterPage()),
    GetPage(name: LOGISTIC, page: () => const LogisticPage()),
    GetPage(name: DELIVERY, page: () => const DeliveryPage()),
    GetPage(name: DELIVERY_DETAILS, page: () => const DeliveryDetailsPage()),
    GetPage(name: REGISTER_DELIVERY, page: () => const RegisterDeliveryPage()),
  ];
}
