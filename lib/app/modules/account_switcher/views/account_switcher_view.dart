// app/modules/account_switcher/views/account_switcher_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart'; // Path ke AuthController
import '../../../models/account_model.dart';     // Path ke model Account
import '../../../routes/app_pages.dart';
import '../controllers/account_switcher_controller.dart';

const Color orangeColors = Color(0xFFE53127);

class AccountSwitcherView extends GetView<AccountSwitcherController> {
  const AccountSwitcherView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan AuthController untuk mengakses savedAccounts secara reaktif
    final AuthController authC = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Akun"),
        // backgroundColor: orangeColors,
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        // leading: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_rounded)),
      ),
      body: Obx(() { // Gunakan Obx untuk merebuild saat savedAccounts berubah
        if (authC.savedAccounts.isEmpty) {
          // Seharusnya tidak pernah sampai sini jika logika di main.dart benar,
          // tapi sebagai fallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
             // controller.loginWithNewAccount(); // Langsung ke login jika tidak ada akun
             // atau
             Get.offAllNamed(Routes.LOGIN); // Lebih aman, karena jika user hapus semua akun dari sini
          });
          return const Center(child: Text("Tidak ada akun tersimpan."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: authC.savedAccounts.length + 1, // +1 untuk tombol "Tambah Akun"
          itemBuilder: (context, index) {
            if (index == authC.savedAccounts.length) {
              // Tombol "Login dengan akun lain" atau "Tambah Akun"
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Login dengan akun lain"),
                  onPressed: controller.loginWithNewAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: orangeColors,
                    side: const BorderSide(color: orangeColors),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              );
            }

            final Account account = authC.savedAccounts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: orangeColors.withOpacity(0.2),
                  child: Icon(Icons.person, color: orangeColors),
                ),
                title: Text(account.email, style: TextStyle(fontWeight: FontWeight.w500)),
                // subtitle: Text("UID: ${account.uid}"), // Bisa untuk debug
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                  onPressed: () => controller.removeAccount(account),
                ),
                onTap: () => controller.selectAccount(account),
              ),
            );
          },
        );
      }),
    );
  }
}