import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Services
import 'package:flutter_getx_app/app/core/service/http_service.dart';
import 'package:flutter_getx_app/app/core/service/storage_service.dart';

// Routes
import 'package:flutter_getx_app/app/routes/app_pages.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser GetStorage
  await GetStorage.init();

  // Initialisation des services
  await initServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter GetX App',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes,
    );
  }
}

/// Initialisation centralisée des services et controllers
Future<void> initServices() async {
  print('Démarrage des services...');

  // 1️⃣ Stockage local
  await Get.putAsync<StorageService>(() => StorageService().init());

  // 2️⃣ HTTP
  Get.put<HttpService>(HttpService(), permanent: true);

  // 3️⃣ Controllers (après services)
  Get.put<HomeController>(HomeController(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  print('Tous les services sont démarrés...');
}
