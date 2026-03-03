import 'package:flutter_getx_app/app/modules/home/contollers/equipment_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/course_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/user_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/training_sessions_controller.dart';
import 'package:flutter_getx_app/controllers/assignments_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/equipments_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/courses_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/home_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/reservations_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/user_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/sessions_view.dart';
import 'package:flutter_getx_app/views/assignments/assignments_list_page.dart';
import 'package:flutter_getx_app/app/modules/spaces/controllers/spaces_controller.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/spaces_view.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/create_space_view.dart';
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
        Get.lazyPut<SpaceController>(() => SpaceController(), fenix: true);
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.CREATE_SPACE,
      page: () => const CreateSpaceView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SpaceController>(() => SpaceController(), fenix: true);
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
    GetPage(
      name: Routes.FORMATIONS,
      page: () => const CoursesView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
        Get.put(CourseController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.SESSIONS,
      page: () => const SessionsView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
        Get.lazyPut<TrainingSessionsController>(
          () => TrainingSessionsController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.DEVOIRS,
      page: () => const AssignmentsListPage(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
        Get.lazyPut<AssignmentsController>(
          () => AssignmentsController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.COMMUNICATION,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
      }),
    ),
  ];
}
