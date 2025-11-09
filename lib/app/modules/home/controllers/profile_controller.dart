// lib/app/modules/home/controllers/profile_controller.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../../controllers/config_controller.dart';
import '../../../controllers/storage_controller.dart';
import '../../../controllers/account_manager_controller.dart';

class ProfileController extends GetxController {
  // --- DEPENDENSI ---
  final ConfigController configC = Get.find<ConfigController>();
  final StorageController storageC = Get.find<StorageController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final AccountManagerController accountManagerC = Get.find<AccountManagerController>();

  final isLoading = false.obs;
  final isSavingNama = false.obs;

  // --- FUNGSI UTAMA ---
  Future<void> ubahFotoProfil() async {
    try {
      // 1. Ambil gambar dari galeri
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // 2. Crop gambar
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Pangkas Foto', lockAspectRatio: true),
          IOSUiSettings(title: 'Pangkas Foto', aspectRatioLockEnabled: true),
        ],
      );
      if (croppedFile == null) return;

      isLoading.value = true;
      
      // 3. [BARU] Panggil fungsi kompresi pada gambar yang sudah di-crop
      File fileToProcess = File(croppedFile.path);
      File? compressedFile = await _compressImage(fileToProcess);
      
      if (compressedFile == null) {
        // Gagal kompresi, hentikan proses
        throw Exception("Gagal memproses gambar.");
      }
      
      // 4. Upload gambar yang SUDAH DIKOMPRES ke Supabase
      final newUrl = await storageC.uploadProfilePicture(compressedFile, configC.infoUser['uid']);

      if (newUrl != null) {
        // 5. Simpan URL baru ke Firestore
        await _firestore
            .collection('Sekolah').doc(configC.idSekolah)
            .collection('siswa').doc(configC.infoUser['uid'])
            .update({'fotoProfilUrl': newUrl});
        
        // 6. Perbarui state lokal agar UI langsung berubah
        configC.infoUser['fotoProfilUrl'] = newUrl;
        Get.snackbar('Berhasil', 'Foto profil berhasil diperbarui.');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mengubah foto: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<File?> _compressImage(File file) async {
    const int targetSizeInBytes = 100 * 1024; // Target 100 KB
    final int initialSize = file.lengthSync();

    if (initialSize <= targetSizeInBytes) {
      print("### Foto profil tidak perlu dikompresi.");
      return file;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final String targetPath = '${tempDir.path}/compressed_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      img.Image? image = img.decodeImage(file.readAsBytesSync());
      if (image == null) return null;

      // Karena sudah di-crop, kita tidak perlu resize besar-besaran.
      // Cukup pastikan tidak lebih besar dari 1080px (ukuran HD standar).
      const int maxDimension = 1080;
      if (image.width > maxDimension || image.height > maxDimension) {
        image = img.copyResize(image, width: maxDimension);
      }

      // Kompresi Kualitas Adaptif
      int quality = 90;
      List<int> compressedBytes;

      do {
        compressedBytes = img.encodeJpg(image, quality: quality);
        print("### Kompresi Profil dengan kualitas $quality. Ukuran: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB");
        
        if (compressedBytes.length > targetSizeInBytes) {
          quality -= 10;
        }
      } while (compressedBytes.length > targetSizeInBytes && quality > 20);

      File compressedFile = await File(targetPath).writeAsBytes(compressedBytes);
      print("### Kompresi Profil FINAL selesai. Ukuran: ${(compressedFile.lengthSync() / 1024).toStringAsFixed(2)} KB");
      
      return compressedFile;

    } catch (e) {
      Get.snackbar("Error Kompresi", "Gagal memproses gambar: ${e.toString()}");
      return null;
    }
  }

  void showEditNamaDialog() {
    final peranKomite = configC.infoUser['peranKomite'] as Map<String, dynamic>?;
    if (peranKomite == null) return; // Pengaman

    final namaC = TextEditingController(text: peranKomite['namaOrangTua'] ?? '');

    Get.defaultDialog(
      title: "Ubah Nama Tampilan Komite",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Nama ini akan digunakan di semua fitur Komite."),
          const SizedBox(height: 16),
          TextField(
            controller: namaC,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Nama Tampilan Anda",
              hintText: "Contoh: Ayah Budi, Bunda Ani"
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
      confirm: Obx(() => ElevatedButton(
        onPressed: isSavingNama.value ? null : () {
          if (namaC.text.isNotEmpty) {
            Get.back();
            updateNamaTampilan(namaC.text);
          } else {
            Get.snackbar("Peringatan", "Nama tidak boleh kosong.");
          }
        },
        child: isSavingNama.value 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text("Simpan"),
      )),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
    );
  }

  Future<void> updateNamaTampilan(String namaBaru) async {
    isSavingNama.value = true;
    try {
      final uidSiswa = configC.infoUser['uid'];
      if (uidSiswa == null) throw Exception("UID Siswa tidak ditemukan.");

      final siswaRef = _firestore.collection('Sekolah').doc(configC.idSekolah)
        .collection('siswa').doc(uidSiswa);

      // 1. Update ke Firestore menggunakan dot notation
      await siswaRef.update({'peranKomite.namaOrangTua': namaBaru});

      // 2. Update state lokal di ConfigController agar UI langsung berubah
      final Map<String, dynamic> peranKomiteLama = Map.from(configC.infoUser['peranKomite']);
      peranKomiteLama['namaOrangTua'] = namaBaru;
      configC.infoUser['peranKomite'] = peranKomiteLama;
      
      Get.snackbar("Berhasil", "Nama tampilan berhasil diubah menjadi: $namaBaru");

    } catch (e) {
      Get.snackbar("Error", "Gagal mengubah nama: ${e.toString()}");
    } finally {
      isSavingNama.value = false;
    }
  }
}