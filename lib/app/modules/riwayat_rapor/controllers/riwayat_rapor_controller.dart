// Di aplikasi ORANG TUA: lib/app/modules/riwayat_rapor/controllers/riwayat_rapor_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../controllers/account_manager_controller.dart';
import '../../../controllers/config_controller.dart';
import '../../../models/rapor_model.dart';
import '../../../routes/app_pages.dart';

class RiwayatRaporController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AccountManagerController _accountManager = Get.find<AccountManagerController>();
  final ConfigController configC = Get.find<ConfigController>();

  // Stream untuk mengambil SEMUA rapor yang pernah dibagikan
  Stream<List<RaporModel>> streamRiwayatRapor() {
    final activeStudent = _accountManager.currentActiveStudent.value;
    if (activeStudent == null) return Stream.value([]);

    // collectionGroup adalah query dahsyat untuk mencari di semua subkoleksi 'rapor'
    return _firestore
        .collectionGroup('rapor')
        .where('idSiswa', isEqualTo: activeStudent.uid)
        .where('idSekolah', isEqualTo: configC.idSekolah) // Filter tambahan untuk keamanan & performa
        .where('isShared', isEqualTo: true)
        .orderBy('tanggalGenerate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RaporModel.fromFirestore(doc)).toList());
      
  }

  void goToDetailRapor(RaporModel rapor) {
    // Untuk saat ini, kita bisa tampilkan snackbar sebagai placeholder
    // Di misi selanjutnya, kita akan buat halaman detailnya.
    // Get.snackbar("Info", "Membuka detail Rapor Semester ${rapor.semester}...");
    // Contoh navigasi ke depan:
    Get.toNamed(Routes.DETAIL_RAPOR, arguments: rapor);
  }
}