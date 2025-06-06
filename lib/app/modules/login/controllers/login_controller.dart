import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart'; // Import AuthController global
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthController authGlobalC = Get.find<AuthController>(); // Dapatkan instance AuthController
  
  RxBool isLoading = false.obs;
  RxBool isLogin = true.obs; // Maksudnya ini untuk visibility password?
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    // Cek apakah ada argumen email yang dikirim (dari AccountSwitcherView)
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['email'] != null) {
      emailC.text = arguments['email'];
    }
  }

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailC.text,
          password: passC.text,
        );

        if (userCredential.user != null) {
          // Simpan akun ke GetStorage melalui AuthController
          await authGlobalC.saveAccount(userCredential.user!);

          if (userCredential.user!.emailVerified == true) {
            isLoading.value = false;
            if (passC.text == "telagailmu") { // Perhatikan case sensitivity jika password ini adalah default
              Get.offAllNamed(Routes.NEW_PASSWORD);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            isLoading.value = false; // Pastikan isLoading false sebelum dialog
            Get.defaultDialog(
              title: 'Belum verifikasi',
              middleText: 'Silahkan verifikasi email Anda terlebih dahulu.',
              actions: [
                OutlinedButton(
                  onPressed: () {
                    // isLoading.value = false; // Sudah di atas
                    Get.back();
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await userCredential.user!.sendEmailVerification();
                      Get.back(); // Tutup dialog
                      Get.snackbar('Berhasil',
                          'Email verifikasi sudah berhasil dikirim ulang. Silakan cek email Anda.');
                      // isLoading.value = false; // Sudah di atas
                    } catch (e) {
                      // isLoading.value = false; // Sudah di atas
                      Get.snackbar(
                          'Terjadi Kesalahan', 'Gagal mengirim email verifikasi. Silahkan dicoba lagi nanti.');
                    }
                  },
                  child: const Text('Kirim Ulang Verifikasi'),
                ),
              ],
            );
          }
        } else {
          // Kondisi ini seharusnya jarang terjadi jika signInWithEmailAndPassword berhasil
          isLoading.value = false;
          Get.snackbar('Terjadi Kesalahan', 'Gagal mendapatkan informasi pengguna.');
        }
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        String errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
        if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Email atau password salah, atau akun belum terdaftar. Mohon periksa kembali.';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
        } else {
          errorMessage = e.message ?? errorMessage; // Gunakan pesan dari Firebase jika ada
        }
        Get.snackbar("Peringatan", errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade300,
            colorText: Colors.white);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Terjadi kesalahan", "Tidak dapat login. Error: ${e.toString()}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade300,
            colorText: Colors.white);
      }
    } else {
      Get.snackbar("Peringatan", "Email & Password Wajib diisi",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade300,
          colorText: Colors.black);
    }
  }

  // Fungsi loginUser dan loginuser sepertinya duplikat atau alternatif dari fungsi login().
  // Sebaiknya disatukan atau dihapus jika tidak digunakan untuk menghindari kebingungan.
  // Saya akan mengomentarinya untuk saat ini.
  /*
  Future<String> loginUser() async { ... }
  void loginuser() async { ... }
  */
}