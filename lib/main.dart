// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart'; // Import GetStorage
// import 'app/controllers/auth_controller.dart'; // Kita akan buat ini nanti
import 'app/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init(); // Inisialisasi GetStorage
  
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.appAttest,
  // );

//   runApp(
//     StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if(snapshot.connectionState == ConnectionState.waiting) {
//           return MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           );
//         }
//         // print('snapshot.data = ${snapshot.data}');
//         return GetMaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: "Application",
//           initialRoute: snapshot.data != null ? Routes.HOME : Routes.LOGIN,
//           // initialRoute: Routes.KELOMPOK_HALAQOH,
//           getPages: AppPages.routes,
//         );
//       }
//     ),
//   );
// }

runApp(MyApp()); // Ubah ini
}

class MyApp extends StatelessWidget {
  // Buat AuthController secara permanen agar bisa diakses dari mana saja
  final AuthController authController = Get.put(AuthController(), permanent: true);

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          // User is logged in with Firebase
          initialRoute = Routes.HOME;
        } else {
          // No Firebase user, check local storage
          if (authController.hasSavedAccounts) {
            initialRoute = Routes.ACCOUNT_SWITCHER; // Kita akan buat route ini
          } else {
            initialRoute = Routes.LOGIN;
          }
        }
        
        // print('Initial route: $initialRoute');
        // print('Saved accounts: ${authController.savedAccounts.length}');

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Application",
          initialRoute: initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}