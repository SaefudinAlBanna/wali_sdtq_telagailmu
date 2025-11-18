// lib/app/modules/login/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';

// [DESAIN BARU] Warna dasar untuk tema Claymorphism
const Color kBackgroundColor = Color(0xFFF0F2F5);
const Color kPrimaryColor = Color(0xFF3949AB); // Indigo 700
const Color kTextColor = Color(0xFF3D4047);

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: controller.isAddingAccount
          ? AppBar(
              title: const Text("Tambah Akun Siswa", style: TextStyle(color: kTextColor)),
              backgroundColor: kBackgroundColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: kTextColor),
            )
          : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === HEADER: LOGO & SAPAAN ===
              SizedBox(
                height: 80,
                width: 80,
                child: Image.asset("assets/png/logo.png"),
              ),
              const SizedBox(height: 24),
              Text(
                controller.isAddingAccount ? "Tambah Akun Anak" : "Selamat Datang",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.isAddingAccount
                    ? "Masukkan email & password siswa"
                    : "Masuk untuk memantau perkembangan Ananda",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              // === FORM CONTAINER DENGAN EFEK CLAYMORPHISM ===
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  // Efek bayangan ganda untuk nuansa timbul
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(4, 4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4, -4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      // Input Email
                      TextFormField(
                        controller: controller.emailC,
                        decoration: _inputDecoration("Email Siswa", Icons.email_outlined),
                        validator: controller.validateEmail,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 20),
                      // Input Password
                      Obx(() => TextFormField(
                            controller: controller.passC,
                            obscureText: controller.isPasswordHidden.value,
                            decoration: _inputDecoration("Password", Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () => controller.isPasswordHidden.toggle(),
                              ),
                            ),
                            validator: controller.validatePassword,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          )),

                        Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: controller.showPasswordHint,
                          child: const Text(
                            "Hint Password?",
                            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // === TOMBOL LOGIN / TAMBAH AKUN DENGAN EFEK CLAYMORPHISM ===
              Obx(() => ClayButton(
                    onPressed: authC.isLoading.value ? null : controller.login,
                    isLoading: authC.isLoading.value,
                    text: controller.isAddingAccount ? "TAMBAH AKUN" : "LOGIN",
                  )),

                  const SizedBox(height: 40),
              // Obx(() => Text(
              //   controller.appVersion.value,
              //   style: TextStyle(
              //     color: Colors.grey.shade700,
              //     fontSize: 12,
              //   ),
              // )),
              Text(
                controller.appVersion,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper untuk styling InputDecoration agar terlihat "cekung"
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      // Latar belakang field yang sedikit berbeda untuk efek cekung
      fillColor: const Color(0xFFE8EAEF),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Tanpa border sama sekali
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}


/// WIDGET CUSTOM UNTUK TOMBOL CLAYMORPHISM
class ClayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const ClayButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade400 : kPrimaryColor,
          borderRadius: BorderRadius.circular(12),
          // Efek bayangan timbul yang lebih halus untuk tombol
          boxShadow: isLoading ? null : [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.5),
              offset: const Offset(5, 5),
              blurRadius: 10,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
          ]
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}

// // lib/app/modules/login/views/login_view.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controllers/auth_controller.dart';
// import '../controllers/login_controller.dart';

// class LoginView extends GetView<LoginController> {
//   const LoginView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final authC = Get.find<AuthController>();
//     return Scaffold(
//       appBar: controller.isAddingAccount ? AppBar(title: const Text("Tambah Akun Siswa"), backgroundColor: Colors.indigo.shade700) : null,
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.shade200, Colors.teal.shade200],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Form(
//                 key: controller.formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       height: 100,
//                       width: 100,
//                       child: Image.asset("assets/png/logo.png"),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       controller.isAddingAccount ? "Tambah Akun Anak" : "Selamat Datang",
//                       style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       controller.isAddingAccount ? "Masukkan akun siswa yang ingin ditambahkan" : "Silakan masuk dengan akun siswa",
//                       style: const TextStyle(fontSize: 16, color: Colors.black54),
//                     ),
//                     const SizedBox(height: 32),
//                     Card(
//                       elevation: 8,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//                         child: Column(
//                           children: [
//                             TextFormField(
//                               controller: controller.emailC,
//                               decoration: InputDecoration(labelText: "Email Siswa", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.email_outlined)),
//                               validator: controller.validateEmail,
//                               autovalidateMode: AutovalidateMode.onUserInteraction,
//                             ),
//                             const SizedBox(height: 16),
//                             Obx(() => TextFormField(
//                                   controller: controller.passC,
//                                   obscureText: controller.isPasswordHidden.value,
//                                   decoration: InputDecoration(
//                                     labelText: "Password",
//                                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                                     prefixIcon: const Icon(Icons.lock_outline),
//                                     suffixIcon: IconButton(
//                                       icon: Icon(controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility),
//                                       onPressed: () => controller.isPasswordHidden.toggle(),
//                                     ),
//                                   ),
//                                   validator: controller.validatePassword,
//                                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                                 )),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Obx(() => SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.indigo.shade700,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               elevation: 4,
//                             ),
//                             onPressed: authC.isLoading.value ? null : controller.login,
//                             child: authC.isLoading.value
//                                 ? const CircularProgressIndicator(color: Colors.white)
//                                 : Text(controller.isAddingAccount ? "TAMBAH AKUN" : "LOGIN", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                           ),
//                         )),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }