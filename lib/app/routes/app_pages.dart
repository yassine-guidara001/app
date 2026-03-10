import 'package:flutter_getx_app/app/modules/home/contollers/equipment_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/course_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/user_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/training_sessions_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/professional_formations_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/professional_profile_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/reservations_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/associations_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/teacher_students_controller.dart';
import 'package:flutter_getx_app/controllers/assignments_controller.dart';
import 'package:flutter_getx_app/app/data/services/associations_service.dart';
import 'package:flutter_getx_app/app/data/services/teacher_students_service.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/equipments_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/courses_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/home_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/my_reservations_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/reservations_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/associations_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/payments_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/professional_profile_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/professional_subscriptions_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/teacher_students_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/association_members_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/user_view.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/sessions_view.dart';
import 'package:flutter_getx_app/views/assignments/assignments_list_page.dart';
import 'package:flutter_getx_app/app/modules/spaces/controllers/spaces_controller.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/spaces_view.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/create_space_view.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/student_spaces_view.dart';
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
      page: () => const DashboardView(),
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
      name: Routes.STUDENT_SPACES,
      page: () => const StudentSpacesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SpaceController>(() => SpaceController(), fenix: true);
        Get.put(HomeController(), permanent: true);
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
      name: Routes.MY_RESERVATIONS,
      page: () => const MyReservationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ReservationsController(), fenix: true);
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.RESERVATIONS,
      page: () => const ReservationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ReservationsController(), fenix: true);
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.ASSOCIATIONS,
      page: () => const AssociationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AssociationsService>(
          () => AssociationsService(),
          fenix: true,
        );
        Get.lazyPut<AssociationsController>(
          () => AssociationsController(),
          fenix: true,
        );
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.PAYMENTS,
      page: () => const PaymentsView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.PROFESSIONAL_SUBSCRIPTIONS,
      page: () => const ProfessionalSubscriptionsView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
      }),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfessionalProfileView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
        Get.lazyPut<ProfessionalProfileController>(
          () => ProfessionalProfileController(),
          fenix: true,
        );
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
        Get.lazyPut<ProfessionalFormationsController>(
          () => ProfessionalFormationsController(),
          fenix: true,
        );
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
      name: Routes.TEACHER_STUDENTS,
      page: () => const TeacherStudentsView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
        Get.lazyPut<TeacherStudentsService>(
          () => TeacherStudentsService(),
          fenix: true,
        );
        Get.lazyPut<TeacherStudentsController>(
          () => TeacherStudentsController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: Routes.ASSOCIATION_MEMBERS,
      page: () => const AssociationMembersView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController(), permanent: true);
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
