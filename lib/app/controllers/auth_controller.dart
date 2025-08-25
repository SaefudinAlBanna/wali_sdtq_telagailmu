// lib/app/controllers/auth_controller.dart (VERSI FINAL & STABIL)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/home/controllers/home_controller.dart';
import '../modules/info_sekolah_list/controllers/info_sekolah_list_controller.dart';
import '../routes/app_pages.dart'; // Import Routes

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;

  // Stream tidak lagi diekspos secara publik karena tidak ada yang mendengarkannya lagi secara langsung.
  // Splash screen menangani logika startup.

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      // Setelah login berhasil, kita navigasi ke Splash screen lagi.
      // Splash screen akan membuat keputusan routing yang benar.
      Get.offAllNamed(Routes.SPLASH);
    } on FirebaseAuthException catch (e) {
      String msg = "Gagal login. Periksa kembali email dan password Anda.";
      if (e.code == 'user-not-found') msg = "Email tidak terdaftar.";
      if (e.code == 'wrong-password') msg = "Password yang Anda masukkan salah.";
      Get.snackbar("Gagal Login", msg, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan yang tidak diketahui.", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> logout() async {
  //   try {
  //     isLoading.value = true;
  //     await auth.signOut();
  //     // Setelah logout, kita navigasi ke Splash screen.
  //     // Splash screen akan mendeteksi tidak ada sesi dan mengarahkan ke Login.
  //     Get.offAllNamed(Routes.SPLASH);
  //   } catch (e) {
  //     Get.snackbar("Error", "Gagal untuk logout. Silakan coba lagi.", snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // --- [PERBAIKAN KEAMANAN] ---
      // Hancurkan controller yang memiliki stream listener aktif secara paksa.
      // Ini akan membatalkan semua subscription ke Firestore SEBELUM signOut().
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>(force: true);
      }
      if (Get.isRegistered<InfoSekolahListController>()) {
        Get.delete<InfoSekolahListController>(force: true);
      }
      // Tambahkan controller lain yang memiliki stream di sini jika ada.
      // ------------------------------------

      await auth.signOut();
      
      // Navigasi ke Splash Screen untuk mereset seluruh state aplikasi
      Get.offAllNamed(Routes.SPLASH);
    } catch (e) {
      Get.snackbar("Error", "Gagal untuk logout. Silakan coba lagi.", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}