import 'package:get/get.dart';

import '../controllers/riwayat_rapor_controller.dart';

class RiwayatRaporBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatRaporController>(
      () => RiwayatRaporController(),
    );
  }
}
