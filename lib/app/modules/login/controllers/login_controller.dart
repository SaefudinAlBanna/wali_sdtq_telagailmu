// lib/app/modules/login/controllers/login_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/account_manager_controller.dart';
import '../../../controllers/config_controller.dart';
import '../views/login_view.dart'; 

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ConfigController configC = Get.find<ConfigController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AccountManagerController _accountManager = Get.find<AccountManagerController>(); 
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isPasswordHidden = true.obs;
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  // final RxString appVersion = "".obs;
  final String appVersion = "Versi 1.0.0"; // [Sementara] Hardcoded version
  bool isAddingAccount = false; 

  @override
  void onInit() {
    super.onInit();
    // [PERBAIKAN] Cek argumen di onInit, tetapi JANGAN tampilkan Snackbar di sini.
    if (Get.arguments is Map && Get.arguments['isAddingAccount'] == true) {
      isAddingAccount = true;
      // [LAMA] Baris ini yang menyebabkan crash, kita pindahkan.
      // Get.snackbar("Tambah Akun", "Silakan masukkan kredensial anak yang ingin ditambahkan.", snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Tampilkan Snackbar di sini, karena ini adalah tempat yang aman.
    // Halaman dijamin sudah selesai di-build pada titik ini.
    if (isAddingAccount) {
      Get.snackbar(
        "Tambah Akun", 
        "Silakan masukkan kredensial anak yang ingin ditambahkan.", 
        snackPosition: SnackPosition.BOTTOM, 
        duration: const Duration(seconds: 5)
      );
    }
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   // _getAppVersion(); // [BARU] Panggil fungsi untuk mengambil versi
  //   if (Get.arguments is Map && Get.arguments['isAddingAccount'] == true) {
  //     isAddingAccount = true;
  //     Get.snackbar("Tambah Akun", "Silakan masukkan kredensial anak yang ingin ditambahkan.", snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
  //   }
  // }

  // Future<void> _getAppVersion() async {
  //   try {
  //     PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //     appVersion.value = "Versi ${packageInfo.version}";
  //   } catch (e) {
  //     print("Error getting app version: $e");
  //     appVersion.value = "Versi 1.0.0"; // Fallback version
  //   }
  // }

  void showPasswordHint() async {
    final email = emailC.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Email Tidak Valid",
        "Silakan masukkan email siswa yang valid terlebih dahulu.",
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final querySnapshot = await _firestore
          .collection('Sekolah')
          .doc(configC.idSekolah)
          .collection('siswa')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // [PERBAIKAN] Cek dulu apakah dialog masih terbuka sebelum menutupnya
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Tutup dialog loading
      }

      if (querySnapshot.docs.isEmpty) {
        _showHintDialog("Email Tidak Ditemukan", "Pastikan email yang Anda masukkan sudah benar dan terdaftar.");
      } else {
        final siswaData = querySnapshot.docs.first.data();
        final hint = siswaData['passwordHint'] as String?;

        if (hint != null && hint.isNotEmpty) {
          _showHintDialog("Hint Password Anda", hint);
        } else {
          _showHintDialog("Hint Tidak Tersedia", "Tidak ada hint password yang diatur untuk akun ini.");
        }
      }
    } catch (e) {
      // [PERBAIKAN] Cek dulu apakah dialog masih terbuka sebelum menutupnya
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Tutup dialog loading jika terjadi error
      }
      _showHintDialog("Terjadi Kesalahan", "Tidak dapat mengambil data. Periksa koneksi internet Anda.");
      print("Error fetching hint: $e");
    }
  }

  void _showHintDialog(String title, String middleText) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: middleText,
      middleTextStyle: const TextStyle(fontSize: 16),
      textConfirm: "Mengerti",
      confirmTextColor: Colors.white,
      buttonColor: kPrimaryColor,
      onConfirm: () => Get.back(),
    );
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      await authController.login(emailC.text, passC.text);
    }
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong.';
    if (!GetUtils.isEmail(value)) return 'Format email tidak valid.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong.';
    return null;
  }

  @override
  void onClose() {
    print("🗑️ [LoginController] onClose called.");
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}