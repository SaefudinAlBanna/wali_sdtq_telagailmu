// app/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/account_model.dart'; // Path ke model Account
import '../routes/app_pages.dart'; // Path ke app_pages

class AuthController extends GetxController {
  final _box = GetStorage();
  final _accountsKey = 'saved_accounts';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  RxList<Account> savedAccounts = <Account>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedAccounts();
    // Dengarkan perubahan status otentikasi Firebase
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        // Jika user logout dari Firebase, arahkan sesuai logika
        if (hasSavedAccounts) {
          Get.offAllNamed(Routes.ACCOUNT_SWITCHER);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      } else {
        // User login, pastikan akunnya tersimpan
        // Ini berguna jika user login dari perangkat lain atau clear data lalu login lagi
        // saveAccount(user); // Atau biarkan LoginController yang handle ini saat login eksplisit
      }
    });
  }

  void _loadSavedAccounts() {
    final List<dynamic>? accountsJson = _box.read<List<dynamic>>(_accountsKey);
    if (accountsJson != null) {
      savedAccounts.value = accountsJson
          .map((json) => Account.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> saveAccount(User firebaseUser) async {
    // Cek apakah akun sudah ada berdasarkan UID
    final existingAccountIndex = savedAccounts.indexWhere((acc) => acc.uid == firebaseUser.uid);

    final newAccount = Account(uid: firebaseUser.uid, email: firebaseUser.email!);

    if (existingAccountIndex != -1) {
      // Jika sudah ada, update (misalnya email jika berubah) dan pindahkan ke atas
      savedAccounts.removeAt(existingAccountIndex);
      savedAccounts.insert(0, newAccount); // Pindahkan ke paling atas (terbaru)
    } else {
      // Jika belum ada, tambahkan ke paling atas
      savedAccounts.insert(0, newAccount);
    }
    _persistAccounts();
  }

  Future<void> removeAccount(Account accountToRemove) async {
    savedAccounts.removeWhere((acc) => acc.uid == accountToRemove.uid);
    _persistAccounts();
    // Jika akun yang dihapus adalah akun yang sedang login di Firebase, logout juga dari Firebase
    if (_firebaseAuth.currentUser?.uid == accountToRemove.uid) {
      await _firebaseAuth.signOut();
    }
    // Jika tidak ada akun tersisa, dan tidak ada user firebase aktif, navigasi ke login
    if (savedAccounts.isEmpty && _firebaseAuth.currentUser == null) {
        Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _persistAccounts() {
    final List<Map<String, dynamic>> accountsJson =
        savedAccounts.map((acc) => acc.toJson()).toList();
    _box.write(_accountsKey, accountsJson);
  }

  bool get hasSavedAccounts => savedAccounts.isNotEmpty;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // Navigasi akan dihandle oleh listener authStateChanges atau StreamBuilder di main.dart
  }
}