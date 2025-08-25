// lib/app/modules/home/controllers/profile_controller.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/config_controller.dart';
import '../../../controllers/storage_controller.dart';

class ProfileController extends GetxController {
  // --- DEPENDENSI ---
  final ConfigController configC = Get.find<ConfigController>();
  final StorageController storageC = Get.find<StorageController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;

  // --- FUNGSI UTAMA ---
  Future<void> ubahFotoProfil() async {
    try {
      // 1. Ambil gambar dari galeri
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // Pengguna membatalkan

      // 2. Crop gambar (UX yang bagus)
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Pangkas Foto', lockAspectRatio: true),
          IOSUiSettings(title: 'Pangkas Foto', aspectRatioLockEnabled: true),
        ],
      );
      if (croppedFile == null) return; // Pengguna membatalkan crop

      // 3. Upload ke Supabase
      isLoading.value = true;
      final fileToUpload = File(croppedFile.path);
      final newUrl = await storageC.uploadProfilePicture(fileToUpload, configC.infoUser['uid']);

      if (newUrl != null) {
        // 4. Simpan URL baru ke Firestore
        await _firestore
            .collection('Sekolah').doc(configC.idSekolah)
            .collection('siswa').doc(configC.infoUser['uid'])
            .update({'fotoProfilUrl': newUrl});
        
        // 5. Perbarui state lokal agar UI langsung berubah
        configC.infoUser['fotoProfilUrl'] = newUrl;
        Get.snackbar('Berhasil', 'Foto profil berhasil diperbarui.');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mengubah foto.');
    } finally {
      isLoading.value = false;
    }
  }
}