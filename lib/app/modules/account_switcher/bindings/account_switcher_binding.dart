import 'package:get/get.dart';

import '../controllers/account_switcher_controller.dart';

class AccountSwitcherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountSwitcherController>(
      () => AccountSwitcherController(),
    );
  }
}
