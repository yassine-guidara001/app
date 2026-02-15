import 'package:flutter_getx_app/app/modules/home/contollers/equipment_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/space_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/user_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/create_space_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/equipments_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/home_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/reservations_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/spaces_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/user_view.dart';
import 'package:get/get.dart';

// Pages
import 'package:flutter_getx_app/pages/login_page.dart';
import 'package:flutter_getx_app/pages/registre_page.dart';

import 'app_routes.dart';

// Controllers
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';

class AppPages {
  static final routes = [
    // Auth
    GetPage(name: Routes.LOGIN, page: () => LoginPage()),
    GetPage(name: Routes.REGISTER, page: () => RegisterPage()),

    // Dashboard Home / Utilisateurs
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
      }),
    ),

    // Autres pages du dashboard
    GetPage(
      name: Routes.SPACES,
      page: () => SpacesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SpaceController());
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.CREATE_SPACE,
      page: () => CreateSpaceView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SpaceController());
      }),
    ),
    GetPage(
      name: Routes.EQUIPMENTS,
      page: () => EquipmentsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EquipmentController());
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.RESERVATIONS,
      page: () => ReservationsView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.USERS,
      page: () => UserView(),
      binding: BindingsBuilder(() {
        Get.put(UserController(), permanent: true);
      }),
    ),
  ];
}
