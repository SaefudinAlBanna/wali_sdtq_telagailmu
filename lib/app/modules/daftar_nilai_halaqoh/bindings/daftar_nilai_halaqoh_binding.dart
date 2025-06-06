import 'package:get/get.dart';

import '../controllers/daftar_nilai_halaqoh_controller.dart';

class DaftarNilaiHalaqohBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarNilaiHalaqohController>(
      () => DaftarNilaiHalaqohController(),
    );
  }
}
