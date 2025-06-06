// app/modules/account_switcher/controllers/account_switcher_controller.dart
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart'; // Path ke AuthController global
import '../../../models/account_model.dart'; // Path ke model Account
import '../../../routes/app_pages.dart';

class AccountSwitcherController extends GetxController {
  final AuthController authC = Get.find<AuthController>(); // Dapatkan instance AuthController

  // RxList<Account> get savedAccounts => authC.savedAccounts; // Akses langsung dari AuthController

  void selectAccount(Account account) {
    // Navigasi ke LoginView dengan email yang sudah diisi
    Get.toNamed(Routes.LOGIN, arguments: {'email': account.email});
  }

  void loginWithNewAccount() {
    Get.toNamed(Routes.LOGIN); // Navigasi ke LoginView tanpa prefill
  }

  void removeAccount(Account account) {
    // Tampilkan dialog konfirmasi
    Get.defaultDialog(
      title: "Hapus Akun",
      middleText: "Anda yakin ingin menghapus akun ${account.email} dari daftar ini? Anda perlu login ulang untuk menggunakannya lagi.",
      textConfirm: "Hapus",
      textCancel: "Batal",
      onConfirm: () {
        authC.removeAccount(account);
        Get.back(); // Tutup dialog
      },
    );
  }
}