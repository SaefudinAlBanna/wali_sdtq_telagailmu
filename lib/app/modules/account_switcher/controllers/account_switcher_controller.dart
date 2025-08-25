// app/modules/account_switcher/controllers/account_switcher_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart'; 
import '../../../models/account_model.dart';
import '../../../routes/app_pages.dart';

class AccountSwitcherController extends GetxController {
  // final AuthController authC = Get.find<AuthController>();

  // // --- FUNGSI INI SEKARANG MEMANGGIL LOGIKA LOGIN OTOMATIS ---
  // void selectAccount(Account account) {
  //   // Panggil fungsi selectAccount dari AuthController yang sudah kita buat
  //   authC.selectAccount(account);
  // }

  // void loginWithNewAccount() {
  //   Get.toNamed(Routes.LOGIN);
  // }

  // void removeAccount(Account account) {
  //   Get.defaultDialog(
  //     title: "Hapus Akun",
  //     middleText: "Anda yakin ingin menghapus akun ${account.email} dari daftar ini?",
  //     textConfirm: "Hapus",
  //     textCancel: "Batal",
  //     confirmTextColor: Colors.white,
  //     onConfirm: () {
  //       // Panggil fungsi removeAccount dari AuthController
  //       authC.removeAccount(account);
  //       Get.back();
  //     },
  //   );
  // }
}