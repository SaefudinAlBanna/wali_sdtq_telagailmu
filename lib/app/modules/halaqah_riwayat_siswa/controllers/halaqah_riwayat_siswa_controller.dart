// lib/app/modules/halaqah_riwayat_siswa/controllers/halaqah_riwayat_siswa_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/config_controller.dart';
import '../../../models/halaqah_setoran_model.dart';

class HalaqahRiwayatSiswaController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConfigController configC = Get.find<ConfigController>();
  final AuthController authC = Get.find<AuthController>();

  final isSending = false.obs;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamRiwayat() {
    final uid = authC.auth.currentUser!.uid;
    return _firestore
        .collection('Sekolah').doc(configC.idSekolah)
        .collection('siswa').doc(uid)
        .collection('halaqah_nilai')
        .orderBy('tanggalTugas', descending: true)
        .snapshots();
  }

  Future<void> kirimCatatan(String setoranId, TextEditingController controller) async {
    final catatan = controller.text.trim();
    if (catatan.isEmpty) {
      Get.snackbar("Peringatan", "Catatan tidak boleh kosong.");
      return;
    }
    
    isSending.value = true;
    try {
      final uid = authC.auth.currentUser!.uid;
      final docRef = _firestore.collection('Sekolah').doc(configC.idSekolah)
        .collection('siswa').doc(uid)
        .collection('halaqah_nilai').doc(setoranId);

      await docRef.update({'catatanOrangTua': catatan});
      
      Get.snackbar("Berhasil", "Catatan Anda telah terkirim.", backgroundColor: Colors.green, colorText: Colors.white);
      controller.clear(); // Kosongkan field setelah berhasil
      Get.focusScope?.unfocus(); // Tutup keyboard

    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim catatan: $e");
    } finally {
      isSending.value = false;
    }
  }

  Future<void> daftarAntrianSetoran(HalaqahSetoranModel setoran) async {
    isSending.value = true; // Gunakan state yang sama untuk loading
    try {
      final uid = authC.auth.currentUser!.uid;
      final namaSiswa = configC.infoUser['namaLengkap'] ?? 'Nama Siswa';
      final waktuSekarang = FieldValue.serverTimestamp();

      // Referensi ke dokumen grup yang sesuai
      // Kita perlu ID grup, yang harus kita tambahkan ke data setoran
      // Untuk sementara, kita asumsikan ID grup ada di 'setoran.idGrup'
      final grupId = setoran.idGrup; // Ini perlu kita tambahkan nanti
      final grupRef = _firestore
          .collection('Sekolah').doc(configC.idSekolah)
          .collection('tahunajaran').doc(setoran.tahunAjaran)
          .collection('halaqah_grup').doc(grupId);

      // Referensi ke dokumen setoran siswa
      final setoranRef = _firestore
          .collection('Sekolah').doc(configC.idSekolah)
          .collection('siswa').doc(uid)
          .collection('halaqah_nilai').doc(setoran.id);

      final WriteBatch batch = _firestore.batch();
      
      // Aksi 1: Update dokumen setoran siswa
      batch.update(setoranRef, {'waktuAntri': waktuSekarang});

      // Aksi 2: Update 'papan antrian' di dokumen grup
      batch.update(grupRef, {
        'antrianSetoran.$uid': {
          'nama': namaSiswa,
          'waktu': waktuSekarang
        }
      });
      
      await batch.commit();
      Get.snackbar("Berhasil", "Anda telah terdaftar dalam antrian setoran.", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) { Get.snackbar("Error", "Gagal mendaftar antrian: $e"); } 
    finally { isSending.value = false; }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamAntrianGrup(HalaqahSetoranModel setoran) {
    if (setoran.idGrup.isEmpty || setoran.tahunAjaran.isEmpty) {
      return const Stream.empty();
    }
    return _firestore
        .collection('Sekolah').doc(configC.idSekolah)
        .collection('tahunajaran').doc(setoran.tahunAjaran)
        .collection('halaqah_grup').doc(setoran.idGrup)
        .snapshots();
  }
}