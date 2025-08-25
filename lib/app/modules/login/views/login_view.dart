import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';

// [VERSI REVITALISASI UI/UX]
class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Gradien
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.teal.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Konten Form Login
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- [PERBAIKAN #1] Logo Aplikasi ---
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset("assets/png/logo.png"),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Selamat Datang",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Silakan masuk dengan akun siswa",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),

                    // --- [PERBAIKAN #2] Form di dalam Card ---
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: controller.emailC,
                              decoration: InputDecoration(labelText: "Email Siswa", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.email_outlined)),
                              validator: controller.validateEmail,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 16),
                            Obx(() => TextFormField(
                                  controller: controller.passC,
                                  obscureText: controller.isPasswordHidden.value,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => controller.isPasswordHidden.toggle(),
                                    ),
                                  ),
                                  validator: controller.validatePassword,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- [PERBAIKAN #3] Tombol Login dengan Gaya Baru ---
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            onPressed: authC.isLoading.value ? null : controller.login,
                            child: authC.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}