// lib/app/modules/home/controllers/home_controller.dart (Aplikasi Orang Tua - VERSI FINAL)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../models/carousel_item_model.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/config_controller.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthController authC = Get.find<AuthController>();
  final ConfigController configC = Get.find<ConfigController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late PersistentTabController tabController;

  // --- [BARU] STATE UNTUK DATA AKADEMIK ---
  final RxString tahunAjaranAktif = "".obs;
  final RxString semesterAktif = "".obs;
  // State ini penting untuk menunggu pengambilan tahun ajaran selesai
  final RxBool isKonfigurasiAkademikLoading = true.obs;

  final RxBool isCarouselLoading = true.obs;
  final RxList<CarouselItemModel> daftarCarousel = <CarouselItemModel>[].obs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _notificationSubscription;
  int _previousUnreadCount = 0;
  
  // --- DEFINISI REFERENSI DOKUMEN SISWA UNTUK KEMUDAHAN ---
  DocumentReference<Map<String, dynamic>> get _siswaDocRef => _firestore
      .collection('Sekolah').doc(configC.idSekolah)
      .collection('siswa').doc(authC.auth.currentUser!.uid);

   @override
  void onInit() {
    super.onInit();
    tabController = PersistentTabController(initialIndex: 0);
    // TIDAK ADA LAGI PANGGILAN _fetchKonfigurasiAkademik di sini. Ini sudah benar.
    _listenToNotifications();
  }

   @override
  void onReady() {
    super.onReady();
    // Gunakan listener untuk auto-refresh jika user logout lalu login lagi
    ever(configC.isKonfigurasiLoading, (bool isLoading) {
      if (!isLoading) { // Jika proses loading konfigurasi selesai
        fetchCarouselData();
      }
    });
    // Panggil sekali saat pertama kali siap
    if (!configC.isKonfigurasiLoading.value) {
      fetchCarouselData();
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    _notificationSubscription?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> fetchCarouselData() async {
    isCarouselLoading.value = true;
    try {
      final now = DateTime.now();
      final todayWithoutTime = DateTime(now.year, now.month, now.day);
      final String tahunAjaran = configC.tahunAjaranAktif.value;
      final String semester = configC.semesterAktif.value;
      final String namaHari = DateFormat('EEEE', 'id_ID').format(now);
      final String kelasId = configC.infoUser['kelasId'] ?? '';

      if (tahunAjaran.isEmpty || tahunAjaran.contains("TIDAK") || kelasId.isEmpty) {
        daftarCarousel.clear(); isCarouselLoading.value = false; return;
      }
      
      // [Prioritas #0: Pesan Pimpinan]
      final pesanPimpinan = configC.konfigurasiDashboard['pesanPimpinan'] as Map<String, dynamic>?;
      if (pesanPimpinan != null) {
        final berlakuHingga = (pesanPimpinan['berlakuHingga'] as Timestamp?)?.toDate();
        if (berlakuHingga != null && now.isBefore(berlakuHingga)) {
          daftarCarousel.assign(CarouselItemModel(namaKelas: "Info Sekolah", tipe: CarouselContentType.Prioritas, judul: "PENGUMUMAN PENTING", isi: pesanPimpinan['pesan'] ?? '', ikon: Icons.campaign_rounded, warna: Colors.red.shade700));
          isCarouselLoading.value = false; return;
        }
      }

      // [Prioritas #1: Kalender Akademik]
      final kalenderSnap = await _firestore.collection('Sekolah').doc(configC.idSekolah).collection('tahunajaran').doc(tahunAjaran).collection('kalender_akademik').where('tanggalMulai', isLessThanOrEqualTo: now).get();
      for (var doc in kalenderSnap.docs) {
        final data = doc.data();
        final tglSelesai = (data['tanggalSelesai'] as Timestamp).toDate();
        if (todayWithoutTime.isBefore(tglSelesai.add(const Duration(days: 1)))) {
          final isLibur = data['isLibur'] as bool? ?? false;
          // --- [PERBAIKAN WARNA] ---
          daftarCarousel.assign(CarouselItemModel(namaKelas: "Info Sekolah", tipe: CarouselContentType.Info, 
          judul: isLibur ? "HARI LIBUR" : "INFO KEGIATAN", isi: data['namaKegiatan'] ?? 'Tanpa Judul', 
          ikon: isLibur ? Icons.weekend_rounded : Icons.event_note_rounded, 
          warna: isLibur ? Colors.red.shade400 : Colors.teal.shade700));
          isCarouselLoading.value = false; return;
        }
      }

      // [Prioritas #2: Hari Libur (Sabtu/Minggu)]
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        final String pesanDefault = "Selamat beristirahat dan tetap semangat belajar di rumah ya!";
        // --- [PERBAIKAN WARNA] ---
        daftarCarousel.assign(CarouselItemModel(namaKelas: "Info Sekolah", tipe: CarouselContentType.Default, 
        judul: "SELAMAT BERAKHIR PEKAN", isi: pesanDefault, 
        ikon: Icons.beach_access_rounded, warna: Colors.blue.shade700));
        isCarouselLoading.value = false; return;
      }
      
      // [Prioritas #3-#6: Logika KBM Siswa]
      final jadwalDoc = await _firestore.collection('Sekolah').doc(configC.idSekolah).collection('tahunajaran').doc(tahunAjaran).collection('jadwalkelas').doc(kelasId).get();
      
      if(jadwalDoc.exists) {
        final jadwalData = jadwalDoc.data()!;
        final listSlot = (jadwalData[namaHari] ?? jadwalData[namaHari.toLowerCase()]) as List? ?? [];
        listSlot.sort((a,b) => (a['jam'] as String).compareTo(b['jam'] as String));

        final nowTime = DateFormat("HH:mm").parse(DateFormat("HH:mm").format(now));
        Map<String, dynamic>? slotBerlangsung;
        Map<String, dynamic>? slotBerikutnya;
        for (var slot in listSlot) { try { final timeParts = (slot['jam'] as String? ?? "00:00-00:00").split('-'); 
        final startTime = DateFormat("HH:mm").parse(timeParts[0].trim()); 
        final endTime = DateFormat("HH:mm").parse(timeParts[1].trim()); 
        if (nowTime.isAfter(startTime) && nowTime.isBefore(endTime)) { slotBerlangsung = slot; break; } 
        if (nowTime.isBefore(startTime) && slotBerikutnya == null) {
           slotBerikutnya = slot; } } catch(e) {} 
           }
        
        CarouselItemModel item;
        if (slotBerlangsung != null) {
          item = CarouselItemModel(namaKelas: "Kelas ${kelasId.split('-').first}", tipe: CarouselContentType.KBM, 
          judul: "Saat Ini Berlangsung", isi: slotBerlangsung['namaMapel'] ?? 'N/A', 
          subJudul: "Oleh: ${slotBerlangsung['namaGuru'] ?? 'N/A'}", ikon: Icons.school_rounded, warna: Colors.indigo.shade700);
        } else if (slotBerikutnya != null) {
          item = CarouselItemModel(namaKelas: "Kelas ${kelasId.split('-').first}", tipe: CarouselContentType.KBM, 
          judul: "Pelajaran Berikutnya", isi: slotBerikutnya['namaMapel'] ?? 'N/A', 
          subJudul: "Jam: ${slotBerikutnya['jam'] ?? 'N/A'}", ikon: Icons.update_rounded, warna: Colors.blue.shade700);
        } else {
          // item = CarouselItemModel(namaKelas: "Info Kelas", tipe: CarouselContentType.Default, judul: "KBM Telah Selesai", isi: "Terima kasih untuk semangat belajarnya hari ini!", ikon: Icons.check_circle_outline_rounded, warna: Colors.grey.shade700);
          item = CarouselItemModel(namaKelas: "Info Kelas", tipe: CarouselContentType.Default, 
          judul: "KBM Telah Selesai", isi: "Terima kasih untuk semangat belajarnya hari ini!", 
          ikon: Icons.check_circle_outline_rounded, warna: Colors.blueGrey.shade700);
        }
        daftarCarousel.assign(item);
      } else {
        // Fallback jika jadwal tidak ditemukan
        daftarCarousel.assign(CarouselItemModel(namaKelas: "Info", tipe: CarouselContentType.Default, judul: "Selamat Belajar!", 
        isi: "Manfaatkan waktu sebaik-baiknya untuk menuntut ilmu.", 
        ikon: Icons.auto_stories, warna: Colors.green.shade800));
      }

    } catch (e) {
      print("### Gagal membangun carousel: $e");
      daftarCarousel.assign(CarouselItemModel(namaKelas: "Error", tipe: CarouselContentType.Default, judul: "GAGAL MEMUAT DATA", isi: "Silakan coba lagi.", ikon: Icons.error_outline_rounded, warna: Colors.grey.shade700));
    } finally {
      isCarouselLoading.value = false;
    }
  }

  void _listenToNotifications() {
    _notificationSubscription = streamNotificationMetadata().listen((snapshot) {
      if (snapshot.exists) {
        final newCount = snapshot.data()?['unreadCount'] ?? 0;
        // Putar suara HANYA jika jumlah notifikasi baru lebih besar dari sebelumnya
        if (newCount > _previousUnreadCount) {
          _playNotificationSound();
        }
        _previousUnreadCount = newCount; // Selalu update hitungan terakhir
      }
    });
  }

  void _playNotificationSound() async {
    try {
      // Pastikan path ini sesuai dengan yang Anda daftarkan di pubspec.yaml
      await _audioPlayer.play(AssetSource('audio/notifikasi.mp3'));
    } catch (e) {
      print("Error saat memutar suara notifikasi: $e");
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSemuaInfoSekolah() {
    final String tahunAjaran = configC.tahunAjaranAktif.value;
    if (tahunAjaran.isEmpty || tahunAjaran.contains("TIDAK")) {
      return const Stream.empty();
    }
    return _firestore
        .collection('Sekolah').doc(configC.idSekolah)
        .collection('tahunajaran').doc(tahunAjaran)
        .collection('info_sekolah')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamInfoDashboard() {
    final String tahunAjaran = configC.tahunAjaranAktif.value;
    if (tahunAjaran.isEmpty || tahunAjaran.contains("TIDAK")) {
      return const Stream.empty();
    }
    return _firestore
        .collection('Sekolah').doc(configC.idSekolah)
        .collection('tahunajaran').doc(tahunAjaran)
        .collection('info_sekolah')
        .orderBy('timestamp', descending: true)
        .limit(5) // <-- KUNCI UTAMA
        .snapshots();
  }

  void goToHalaqahRiwayat() {
    Get.toNamed(Routes.HALAQAH_RIWAYAT_SISWA);
  }

  void goToJadwalSiswa() {
  Get.toNamed(Routes.JADWAL_SISWA);
}

  void goToSemuaInformasi() {
    Get.toNamed(Routes.INFO_SEKOLAH_LIST);
  }

  void goToEkskulSiswa() {
    Get.toNamed(Routes.EKSKUL_SISWA);
  }

  void goToKalenderAkademik() {
    Get.toNamed(Routes.KALENDER_AKADEMIK);
  }

  void logout() {
    authC.logout();
  }

  void goToEditProfil() {
    Get.toNamed(Routes.LENGKAPI_PROFIL, arguments: configC.infoUser);
  }


  void goToDaftarMapel() {
    Get.toNamed(Routes.DAFTAR_MATA_PELAJARAN);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserData() {
    return _siswaDocRef.snapshots();
  }

  // --- [BARU] STREAM UNTUK NOTIFIKASI TERBARU DI DASHBOARD ---
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLatestNotifications() {
    return _siswaDocRef
        .collection('notifikasi')
        .orderBy('tanggal', descending: true)
        .limit(5) // Mengambil 5 notifikasi terbaru
        .snapshots();
  }
  
  // --- [BARU] STREAM UNTUK METADATA NOTIFIKASI (UNREAD COUNT) ---
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamNotificationMetadata() {
    return _siswaDocRef
        .collection('notifikasi_meta')
        .doc('metadata')
        .snapshots();
  }

  // --- [BARU] FUNGSI UNTUK NAVIGASI DAN RESET UNREAD COUNT ---
  void goToSemuaNotifikasi() {
    // Reset unread count menjadi 0 di Firestore
    _siswaDocRef
        .collection('notifikasi_meta')
        .doc('metadata')
        .set({'unreadCount': 0}, SetOptions(merge: true));
    
    // Navigasi ke halaman daftar semua notifikasi
    Get.toNamed(Routes.SEMUA_NOTIFIKASI);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMataPelajaranSiswa() {
    // Ambil kelasId dari infoUser yang sudah ada di ConfigController
    final String kelasId = configC.infoUser['kelasId'] ?? '';
    
    // Pastikan semua data yang dibutuhkan sudah siap
    if (kelasId.isEmpty || tahunAjaranAktif.value.isEmpty || semesterAktif.value.isEmpty) {
      // Kembalikan stream kosong jika data belum siap
      return const Stream.empty();
    }

    return _siswaDocRef
        .collection('matapelajaran')
        .snapshots();
  }
}