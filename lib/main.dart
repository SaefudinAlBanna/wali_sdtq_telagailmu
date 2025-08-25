// lib/main.dart (Aplikasi Orang Tua - DENGAN URUTAN YANG BENAR)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'app/controllers/storage_controller.dart';

import 'app/controllers/auth_controller.dart';
import 'app/controllers/config_controller.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await supabase.Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await GetStorage.init();
  await initializeDateFormatting('id_ID', null);

  // --- PERBAIKAN URUTAN KRUSIAL DI SINI ---
  // 1. Daftarkan ConfigController TERLEBIH DAHULU, karena AuthController bergantung padanya.
  Get.put(ConfigController(), permanent: true);
  
  // 2. Baru daftarkan AuthController.
  Get.put(AuthController(), permanent: true);
  Get.put(StorageController(), permanent: true);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Wali PKBM Telagailmu",
      initialRoute: AppPages.INITIAL, // Akan mengarah ke '/splash'
      getPages: AppPages.routes,
    ),
  );
}