// lib/app/controllers/config_controller.dart (Aplikasi ORANG TUA - VERSI FINAL & LENGKAP)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/app_pages.dart';

class ConfigController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

  late final String idSekolah;
  final RxMap<String, dynamic> infoUser = <String, dynamic>{}.obs;

  final RxString tahunAjaranAktif = "".obs;
  final RxString semesterAktif = "".obs;
  final RxBool isKonfigurasiLoading = true.obs;
  late Future<void> konfigurasiFuture;

  final RxMap<String, dynamic> konfigurasiDashboard = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    idSekolah = dotenv.env['ID_SEKOLAH']!;
    // --- MODIFIKASI PANGGILAN INI ---
    // konfigurasiFuture = Future.wait([
    //   _fetchKonfigurasiAkademik(),
    //   _syncKonfigurasiDashboard(), // Jalankan secara paralel
    // ]);
  }

  Future<void> initAuthenticatedData() async {
    // Fungsi ini akan dipanggil SETELAH kita tahu pengguna sudah login.
    isKonfigurasiLoading.value = true;
    // Kita jalankan keduanya secara paralel untuk efisiensi.
    await Future.wait([
      _fetchKonfigurasiAkademik(),
      _syncKonfigurasiDashboard(),
    ]);
    isKonfigurasiLoading.value = false;
  }

  Future<void> _syncKonfigurasiDashboard() async {
    try {
      final doc = await _firestore
          .collection('Sekolah').doc(idSekolah)
          .collection('pengaturan').doc('konfigurasi_dashboard')
          .get();
      if (doc.exists && doc.data() != null) {
        konfigurasiDashboard.value = doc.data()!;
      }
    } catch (e) {
      print("### Gagal mengambil konfigurasi dashboard: $e");
    }
  }

  Future<void> _fetchKonfigurasiAkademik() async {
    try {
      isKonfigurasiLoading.value = true;
      final snapshot = await _firestore
          .collection('Sekolah').doc(idSekolah)
          .collection('tahunajaran')
          .where('isAktif', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        tahunAjaranAktif.value = doc.id;
        semesterAktif.value = doc.data()['semesterAktif']?.toString() ?? '1';
      } else {
        tahunAjaranAktif.value = "TIDAK_AKTIF";
      }
    } catch (e) {
      tahunAjaranAktif.value = "ERROR";
      print("### Gagal memuat konfigurasi akademik: $e");
    } finally {
      isKonfigurasiLoading.value = false;
    }
  }

  // Future<String> decideInitialRoute() async {
  //   final user = _auth.currentUser;
  //   if (user == null) return Routes.LOGIN;

  //   try {
  //     final userDoc = await _firestore.collection('Sekolah').doc(idSekolah).collection('siswa').doc(user.uid).get();

  //     if (userDoc.exists && userDoc.data() != null) {
  //       final profile = userDoc.data()!;
  //       final Map<String, dynamic> sanitizedProfile = Map<String, dynamic>.from(profile);
  //       sanitizedProfile.forEach((key, value) {
  //         if (value is Timestamp) {
  //           sanitizedProfile[key] = value.toDate().toIso8601String();
  //         }
  //       });
        
  //       infoUser.value = sanitizedProfile;
  //       await _box.write('userProfile', sanitizedProfile);
        
  //       if (profile['mustChangePassword'] == true) {
  //         return Routes.NEW_PASSWORD;
  //       } else if (profile['isProfileComplete'] == false) {
  //         return Routes.LENGKAPI_PROFIL;
  //       } else {
  //         return Routes.HOME;
  //       }
  //     } else {
  //       throw Exception("Profil tidak valid.");
  //     }
  //   } catch (e) {
  //     await _box.remove('userProfile');
  //     await _auth.signOut();
  //     return Routes.LOGIN;
  //   }
  // }

  Future<String> decideInitialRoute() async {
    final user = _auth.currentUser;
    if (user == null) return Routes.LOGIN;

    try {
      final userDoc = await _firestore.collection('Sekolah').doc(idSekolah).collection('siswa').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        // --- [PERBAIKAN KRUSIAL] ---
        // Panggil fungsi inisialisasi data PENTING di sini.
        // `await` memastikan data ini selesai dimuat SEBELUM navigasi ke HOME.
        await initAuthenticatedData(); 
        // -----------------------------

        final profile = userDoc.data()!;
        final Map<String, dynamic> sanitizedProfile = Map<String, dynamic>.from(profile);
        sanitizedProfile.forEach((key, value) {
          if (value is Timestamp) {
            // sanitizedProfile[key] = value.toDate().toIso86is_profile_completeIso8601String();
            sanitizedProfile[key] = value.toDate().toIso8601String();
          }
        });
        
        infoUser.value = sanitizedProfile;
        await _box.write('userProfile', sanitizedProfile);
        
        if (profile['mustChangePassword'] == true) {
          return Routes.NEW_PASSWORD;
        } else if (profile['isProfileComplete'] == false) {
          return Routes.LENGKAPI_PROFIL;
        } else {
          return Routes.HOME;
        }
      } else {
        throw Exception("Profil tidak valid.");
      }
    } catch (e) {
      await _box.remove('userProfile');
      await _auth.signOut();
      return Routes.LOGIN;
    }
  }
  
  Future<void> clearCache() async {
    await _box.remove('userProfile');
    infoUser.clear();
  }
}