// Di aplikasi ORANG TUA: lib/app/modules/detail_rapor/controllers/detail_rapor_controller.dart

import 'package:get/get.dart';
import '../../../controllers/config_controller.dart';
import '../../../models/rapor_model.dart';

class DetailRaporController extends GetxController {

  final ConfigController configC = Get.find<ConfigController>();
  
  // State untuk menampung data rapor yang diterima
  final Rxn<RaporModel> rapor = Rxn<RaporModel>();

  @override
  void onInit() {
    super.onInit();
    // Ambil objek RaporModel dari argumen navigasi
    if (Get.arguments != null && Get.arguments is RaporModel) {
      rapor.value = Get.arguments as RaporModel;
    } else {
      // Jika argumen tidak valid, tampilkan error
      Get.snackbar("Error", "Gagal memuat data rapor. Argumen tidak valid.");
    }
  }
}