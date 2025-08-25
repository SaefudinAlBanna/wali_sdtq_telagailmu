// lib/app/modules/splash/controllers/splash_controller.dart (DIPERBAIKI)

import 'package:get/get.dart';

import '../../../controllers/config_controller.dart';

class SplashController extends GetxController {
  final ConfigController configC = Get.find<ConfigController>();

  @override
  void onReady() {
    super.onReady();
    _initialize();
  }

  Future<void> _initialize() async {
    // Beri sedikit jeda agar UI splash terlihat
    await Future.delayed(const Duration(seconds: 2));
    
    // --- PERBAIKAN DI SINI ---
    // Panggil nama fungsi yang benar: 'decideInitialRoute'
    final String initialRoute = await configC.decideInitialRoute();
    
    // Lakukan navigasi final
    Get.offAllNamed(initialRoute);
  }
}