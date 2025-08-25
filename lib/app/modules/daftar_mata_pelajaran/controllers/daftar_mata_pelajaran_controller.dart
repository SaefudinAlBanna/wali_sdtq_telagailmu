// lib/app/modules/daftar_mata_pelajaran/controllers/daftar_mata_pelajaran_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/config_controller.dart';
import '../../../models/mapel_siswa_model.dart';
import '../../../routes/app_pages.dart';

class DaftarMataPelajaranController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authC = Get.find<AuthController>();
  final ConfigController configC = Get.find<ConfigController>();

  final RxString tahunAjaranAktif = "".obs;
  final RxString semesterAktif = "".obs;
  final RxBool isKonfigurasiLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchKonfigurasiAkademik();
  }

  Future<void> _fetchKonfigurasiAkademik() async {
    try {
      isKonfigurasiLoading.value = true;
      final snapshot = await _firestore
          .collection('Sekolah').doc(configC.idSekolah)
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
      Get.snackbar("Error", "Gagal memuat konfigurasi akademik.");
      tahunAjaranAktif.value = "ERROR";
    } finally {
      isKonfigurasiLoading.value = false;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMataPelajaranSiswa() {
    final uid = authC.auth.currentUser?.uid;
    final kelasId = configC.infoUser['kelasId'] as String?;

    if (uid == null || kelasId == null || kelasId.isEmpty || tahunAjaranAktif.value.isEmpty || tahunAjaranAktif.value.contains("TIDAK_AKTIF")) {
      return Future.error("Data konfigurasi tidak lengkap.");
    }
    
    // --- [FIX] Path diubah ke koleksi spesifik milik siswa ---
    return _firestore
        .collection('Sekolah').doc(configC.idSekolah)
        .collection('tahunajaran').doc(tahunAjaranAktif.value)
        .collection('kelastahunajaran').doc(kelasId)
        .collection('semester').doc(semesterAktif.value)
        .collection('daftarsiswa').doc(uid)
        .collection('matapelajaran')
        .orderBy('namaMapel')
        .get(); 
  }
  
  void goToDetailMapel(MapelSiswaModel mapel) {
    // Navigasi ke Halaman Detail (Tahap 2)
    // Untuk sekarang, kita beri Snackbar
    Get.toNamed(
      Routes.DETAIL_MAPEL_SISWA, // Ini akan kita buat di Tahap 2
      arguments: {
        'idMapel': mapel.id,
        'namaMapel': mapel.namaMapel,
        'namaGuru': mapel.namaGuru,
        'tahunAjaran': tahunAjaranAktif.value,
        'semester': semesterAktif.value,
        'kelasId': configC.infoUser['kelasId'],
      }
    );
  }
}