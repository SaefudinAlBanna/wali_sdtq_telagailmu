// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'app/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Supabase dengan prefix 'as supabase' untuk menghindari konflik nama 'User'
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inisialisasi Firebase (tidak berubah)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Supabase dengan prefix
  await supabase.Supabase.initialize(
    url: 'https://dbhruouikurccpsmildt.supabase.co', // <-- Ganti dengan URL Anda
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRiaHJ1b3Vpa3VyY2Nwc21pbGR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzNjA3MzgsImV4cCI6MjA2NDkzNjczOH0.XJ5SIwSqkogq1BnQOqMM_W1JxUcqtasophiIADwj2b0',         // <-- Ganti dengan Anon Key Anda
  );
  
  await GetStorage.init();
  
  // Kode runApp Anda tidak perlu diubah karena semua referensi 'User'
  // sekarang secara otomatis merujuk ke User dari Firebase.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(AuthController(), permanent: true);

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Di sini, 'User?' akan secara otomatis merujuk ke User dari firebase_auth
    // karena User dari supabase sekarang harus dipanggil supabase.User
    return StreamBuilder<User?>( 
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        String initialRoute;
        if (snapshot.hasData && snapshot.data != null) {
          initialRoute = Routes.HOME;
        } else {
          if (authController.hasSavedAccounts) {
            initialRoute = Routes.ACCOUNT_SWITCHER;
          } else {
            initialRoute = Routes.LOGIN;
          }
        }
        
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "SDTQ Telaga Ilmu",
          initialRoute: initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}