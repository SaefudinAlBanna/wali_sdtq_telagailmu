import 'package:get/get.dart';

import '../controllers/detail_rapor_controller.dart';

class DetailRaporBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailRaporController>(
      () => DetailRaporController(),
    );
  }
}
