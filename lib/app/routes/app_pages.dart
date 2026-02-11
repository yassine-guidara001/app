import 'package:flutter_getx_app/pages/login_page.dart';
import 'package:flutter_getx_app/pages/registre_page.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/home_view.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:get/get.dart';


class AppPages {
  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => LoginPage()),
    GetPage(name: Routes.REGISTER, page: () => RegisterPage()),
    GetPage(name: Routes.HOME, page: () => HomeView()),
  ];
}
