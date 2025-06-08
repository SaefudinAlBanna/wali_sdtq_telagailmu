// home_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/storage_controller.dart'; // <-- Tambahkan import

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Daftarkan StorageController agar bisa diakses
    Get.lazyPut<StorageController>(
      () => StorageController(),
    );
  }
}