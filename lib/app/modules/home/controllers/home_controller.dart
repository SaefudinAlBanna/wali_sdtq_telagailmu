import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:async';

import '../../../routes/app_pages.dart';
import '../pages/home.dart';
import '../pages/marketplace.dart';
import '../pages/profile.dart';

import 'dart:io'; // <-- Tambahkan import
import 'package:image_picker/image_picker.dart'; // <-- Tambahkan import
import 'storage_controller.dart'; // <-- Tambahkan import
import 'package:image_cropper/image_cropper.dart'; 


class HomeController extends GetxController {

  final StorageController storageC = Get.find(); // <-- Dapatkan instance StorageController

  RxInt indexWidget = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingInitialData = true.obs; // Untuk loading tahun ajaran & kelas
  RxString jamPelajaranRx = 'Memuat jam...'.obs;

  RxList<DocumentSnapshot<Map<String, dynamic>>> kelasAktifList =
      <DocumentSnapshot<Map<String, dynamic>>>[].obs;

  Timer? _timer;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String idUser = FirebaseAuth.instance.currentUser!.uid;
  String idSekolah = "P9984539";
  String emailAdmin = FirebaseAuth.instance.currentUser!.email!;

  late String docIdSiswa;
  String? idTahunAjaran;

  @override
  void onInit() async {
    super.onInit();
    idSiswa()
        .then((value) {
          docIdSiswa = value;
        })
        .catchError((error) {
          Get.snackbar('Error', 'Error initializing docIdSiswa: $error');
          // print('Error initializing docIdSiswa: $error');
        });
     _initializeController();
    isLoading.value = true; // Set loading state
    try {
      String tahunAjaranAktif = await getTahunAjaranTerakhir();
      idTahunAjaran = tahunAjaranAktif.replaceAll("/", "-");
      jamPelajaranRx.value = getJamPelajaranSaatIni();
      print('HomeController onInit: idTahunAjaran = $idTahunAjaran, jamPelajaranRx = ${jamPelajaranRx.value}');
      update(); // Untuk GetBuilder jika ada yang bergantung pada idTahunAjaran
    } catch (e) {
      print("Error initializing HomeController: $e");
      // Handle error, mungkin tampilkan pesan ke user
    } finally {
      isLoading.value = false;
    }

    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      final newJam = getJamPelajaranSaatIni();
      if (newJam != jamPelajaranRx.value) {
        jamPelajaranRx.value = newJam;
        print('HomeController Timer: jamPelajaranRx updated to ${jamPelajaranRx.value}');
        // Tidak perlu update() di sini jika UI menggunakan Obx untuk jamPelajaranRx
      }
    });
  }

  // FUNGSI BARU UNTUK MEMILIH DAN MENGUPLOAD FOTO
  Future<void> pickAndUploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    // Pilih gambar dari galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // --- LANGKAH CROPPING DIMULAI DI SINI ---
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Set square aspect ratio
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Potong Gambar',
              toolbarColor: Colors.indigo[400], // Sesuaikan dengan tema Anda
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true), // Kunci rasio menjadi persegi
          IOSUiSettings(
            title: 'Potong Gambar',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );
      // --- LANGKAH CROPPING SELESAI ---

      // Lanjutkan hanya jika pengguna selesai cropping (tidak menekan cancel)
      if (croppedFile != null) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          // Gunakan file yang sudah di-crop, bukan file asli
          final File imageFile = File(croppedFile.path); 
          final String uid = auth.currentUser!.uid;

          // 1. Upload ke Supabase Storage
          final String? imageUrl = await storageC.uploadProfilePicture(imageFile, uid);

          if (imageUrl != null) {
            // 2. Dapatkan docIdSiswa untuk update Firestore
            final String siswaDocId = await idSiswa();
            
            // 3. Simpan URL dari Supabase ke dokumen user di Firestore
            await firestore
                .collection('Sekolah')
                .doc(idSekolah)
                .collection('siswa')
                .doc(siswaDocId)
                .update({'profileImageUrl': imageUrl});
            
            Get.back(); // Tutup dialog loading
            Get.snackbar('Sukses', 'Foto profil berhasil diperbarui!');
          } else {
             Get.back();
          }
        } catch (e) {
          Get.back();
          Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
        }
      }
    }
  }
      // Tampilkan dialog loading
  //     Get.dialog(
  //       const Center(child: CircularProgressIndicator()),
  //       barrierDismissible: false,
  //     );

  //     try {
  //       final File imageFile = File(image.path);
  //       final String uid = auth.currentUser!.uid;

  //       // 1. Upload ke Supabase Storage
  //       final String? imageUrl = await storageC.uploadProfilePicture(imageFile, uid);

  //       if (imageUrl != null) {
  //         // 2. Dapatkan docIdSiswa untuk update Firestore
  //         final String siswaDocId = await idSiswa();
          
  //         // 3. Simpan URL dari Supabase ke dokumen user di Firestore
  //         await firestore
  //             .collection('Sekolah')
  //             .doc(idSekolah)
  //             .collection('siswa')
  //             .doc(siswaDocId)
  //             .update({'profileImageUrl': imageUrl}); // <-- Simpan di field baru
          
  //         Get.back(); // Tutup dialog loading
  //         Get.snackbar('Sukses', 'Foto profil berhasil diperbarui!');
  //       } else {
  //          Get.back(); // Tutup dialog loading jika gagal
  //       }

  //     } catch (e) {
  //       Get.back(); // Tutup dialog loading
  //       Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
  //     }
  //   }
  // }

  Future<String> getTahunAjaranTerakhir() async {
    CollectionReference<Map<String, dynamic>> colTahunAjaran = firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('tahunajaran');
    QuerySnapshot<Map<String, dynamic>> snapshotTahunAjaran =
        await colTahunAjaran.get();
    List<Map<String, dynamic>> listTahunAjaran =
        snapshotTahunAjaran.docs.map((e) => e.data()).toList();
    String tahunAjaranTerakhir =
        listTahunAjaran.map((e) => e['namatahunajaran']).toList().last;
    return tahunAjaranTerakhir;
  }

  String getJamPelajaranSaatIni() {
  DateTime now = DateTime.now();
  int currentMinutes = now.hour * 60 + now.minute;
  print('currentMinutes: $currentMinutes');
  List<String> jamPelajaran = [
    '07-00-07.05',
    '07.05-07.30',
    '08.00-08.45',

  ];
  for (String jam in jamPelajaran) {
    List<String> range = jam.split('-');
    int startMinutes = _parseToMinutes(range[0]);
    int endMinutes = _parseToMinutes(range[1]);
    print('Cek: $currentMinutes >= $startMinutes && $currentMinutes < $endMinutes');
    if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
      print('MATCH: $jam');
      return jam;
    }
  }
  print('Tidak ada jam pelajaran');
  return 'Tidak ada jam pelajaran';
}

int _parseToMinutes(String hhmm) {
  List<String> parts = hhmm.split('.');
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);
  return hour * 60 + minute;
}

  Future<void> _initializeController() async {
    isLoadingInitialData.value = true;
    if (auth.currentUser == null) {
      print("Error: Pengguna belum login.");
      // Mungkin redirect ke login atau tampilkan pesan error
      Get.snackbar("Error", "Sesi tidak valid, silakan login ulang.");
      isLoadingInitialData.value = false;
      jamPelajaranRx.value = "Error: Sesi tidak valid";
      // Consider calling signOut() or navigating to login
      return;
    }
    idUser = auth.currentUser!.uid;
    emailAdmin = auth.currentUser!.email!;

    try {
      String tahunAjaranAktif = await _getTahunAjaranTerakhir();
      idTahunAjaran = tahunAjaranAktif.replaceAll("/", "-");
      print('HomeController: idTahunAjaran diinisialisasi menjadi $idTahunAjaran');

      await _fetchKelasAktif(); // Ambil daftar kelas

      jamPelajaranRx.value = _getJamPelajaranSaatIni();
      _startTimer();
      update(); // Untuk GetBuilder yang mungkin bergantung pada _idTahunAjaran
    } catch (e) {
      print("Error initializing HomeController: $e");
      Get.snackbar("Kesalahan Inisialisasi", "Gagal memuat data awal: ${e.toString()}");
      jamPelajaranRx.value = "Error memuat data";
    } finally {
      isLoadingInitialData.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel timer lama jika ada
    _timer = Timer.periodic(Duration(seconds: 30), (timer) { // Interval 30 detik untuk testing
      final newJam = _getJamPelajaranSaatIni();
      if (newJam != jamPelajaranRx.value) {
        jamPelajaranRx.value = newJam;
        print('HomeController Timer: jamPelajaranRx updated to ${jamPelajaranRx.value}');
      }
    });
  }

  String _getJamPelajaranSaatIni() {
    DateTime now = DateTime.now();
    int currentMinutes = now.hour * 60 + now.minute;

    // List ID dokumen jam pelajaran yang ada di Firestore Anda
    // Format ID ini HARUS PERSIS seperti di subkoleksi 'jurnalkelas'
    // Contoh: '07-00-07.05', '07.05-07.30'
    List<Map<String, String>> jadwalPelajaran = [
      {'id': '07-00-07.05', 'start': '07.00', 'end': '07.05'},
      {'id': '07.05-07.30', 'start': '07.05', 'end': '07.30'},
      {'id': '21.30-21.55', 'start': '21.30', 'end': '21.55'},
      {'id': '21.55-22.08', 'start': '21.55', 'end': '22.08'},
      {'id': '22.08-22.10', 'start': '22.08', 'end': '22.10'},
      {'id': '22.10-22.20', 'start': '22.10', 'end': '22.20'},
      // Tambahkan semua slot jam Anda di sini
    ];

    for (var jadwal in jadwalPelajaran) {
      try {
        int startMinutes = _parseTimeToMinutes(jadwal['start']!);
        int endMinutes = _parseTimeToMinutes(jadwal['end']!);

        if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
          return jadwal['id']!;
        }
      } catch (e) {
        print("Error parsing jadwal ${jadwal['id']}: $e. Pastikan format start/end HH.MM");
        continue;
      }
    }
    return 'Tidak ada jam pelajaran';
  }

  int _parseTimeToMinutes(String hhmm) { // Format HH.MM
    List<String> parts = hhmm.split('.');
    if (parts.length != 2) throw FormatException("Format waktu tidak valid: $hhmm. Harusnya HH.MM");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<String> _getTahunAjaranTerakhir() async {
    QuerySnapshot<Map<String, dynamic>> snapshotTahunAjaran = await firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('tahunajaran')
        // Anda mungkin perlu order by field tertentu jika ingin yang "terakhir" secara kronologis
        // .orderBy('tanggalDibuat', descending: true) // Contoh jika ada field 'tanggalDibuat'
        .get();

    if (snapshotTahunAjaran.docs.isEmpty) {
      throw Exception("Tidak ada data tahun ajaran ditemukan.");
    }
    // Mengambil yang terakhir berdasarkan ID dokumen jika ID nya bisa diurutkan (misal "2023-2024", "2024-2025")
    // Atau jika field 'namatahunajaran' bisa diurutkan
    List<String> namaTahunAjaranList = snapshotTahunAjaran.docs
        .map((doc) => doc.data()['namatahunajaran'] as String)
        .toList();
    namaTahunAjaranList.sort(); // Sorts alphabetically/numerically
    if (namaTahunAjaranList.isEmpty) throw Exception("List nama tahun ajaran kosong setelah map.");
    return namaTahunAjaranList.last;
  }

  Future<void> _fetchKelasAktif() async {
    if (idTahunAjaran == null) {
      print("Tidak bisa fetch kelas aktif, idTahunAjaran null.");
      kelasAktifList.clear();
      return;
    }
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('Sekolah')
          .doc(idSekolah)
          .collection('tahunajaran')
          .doc(idTahunAjaran!)
          .collection('kelasaktif')
          .get();
      kelasAktifList.assignAll(snapshot.docs);
      print("Kelas aktif berhasil diambil: ${kelasAktifList.length} kelas");
    } catch (e) {
      print("Error fetching kelas aktif: $e");
      Get.snackbar("Error", "Gagal memuat daftar kelas: ${e.toString()}");
      kelasAktifList.clear();
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getStreamJurnalDetail(
    String idKelas,
    String jamPelajaranDocId,
   ) {
    if (idTahunAjaran == null || jamPelajaranDocId == 'Tidak ada jam pelajaran' || jamPelajaranDocId.isEmpty || jamPelajaranDocId == 'Memuat jam...') {
      // Return an empty stream if no valid jamPelajaranDocId
      // kode sebelumnya dari ai
      //  return Stream.value(FirestoreQueryBuilder.emptyDocumentSnapshot()); -> ERROR
      return const Stream.empty();
    }
    DateTime now = DateTime.now();
    String docIdTanggalJurnal = DateFormat('d-M-yyyy').format(now); // Sesuai path Anda: "6-2-2025"

    return firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('tahunajaran')
        .doc(idTahunAjaran!)
        .collection('kelasaktif')
        .doc(idKelas)
        .collection('tanggaljurnal')
        .doc(docIdTanggalJurnal)
        .collection('jurnalkelas')
        .doc(jamPelajaranDocId) // Ini adalah ID dokumen jam pelajaran
        .snapshots();
  }

  Future<String> idSiswa() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshotSiswa =
        await firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('siswa')
            .where('uid', isEqualTo: idUser)
            .get();
    if (querySnapshotSiswa.docs.isNotEmpty) {
      Map<String, dynamic> dataSiswa = querySnapshotSiswa.docs.first.data();
      String docIdSiswa = dataSiswa['nisn'];

      return docIdSiswa;
    } else {
      throw Exception('No student found for the current user.');
    }
  }

  void changeIndex(int index) {
    indexWidget.value = index;
  }

  final List<Widget> myWidgets = [HomePage(), MarketplacePage(), ProfilePage()];

  void signOut() async {
    isLoading.value = true;
    await auth.signOut();
    isLoading.value = false;
    Get.offAllNamed('/login');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStreamBaru() async* {
    QuerySnapshot<Map<String, dynamic>> querySnapshotSiswa =
        await firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('siswa')
            .where('uid', isEqualTo: idUser)
            .get();
    if (querySnapshotSiswa.docs.isNotEmpty) {
      Map<String, dynamic> dataSiswa = querySnapshotSiswa.docs.first.data();
      String docIdSiswa = dataSiswa['nisn'];

      // String docIdSiswa = await idSiswa();

      yield* firestore
          .collection('Sekolah')
          .doc(idSekolah)
          .collection('siswa')
          .doc(docIdSiswa)
          .snapshots();
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getProfileBaru() async* {
    yield* firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('siswa')
        .doc(docIdSiswa)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDataKelas() async {
    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");

    QuerySnapshot<Map<String, dynamic>> snapColKelas =
        await firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('siswa')
            .doc(docIdSiswa)
            .collection('tahunajaran')
            .doc(idTahunAjaran)
            .collection('kelasnya')
            .get();

    if (snapColKelas.docs.isNotEmpty) {
      return snapColKelas;
    } else {
      throw Exception('No class data found for the current student.');
    }
  }

  // Future<DocumentSnapshot<Map<String, dynamic>>> getDataDocKelasSiswa() async {
  //   String tahunajaranya = await getTahunAjaranTerakhir();
  //   String idTahunAjaran = tahunajaranya.replaceAll("/", "-");
  //   String idKelasnya = await getDataKelas();

  //   // ignore: non_constant_identifier_names
  //   CollectionReference<Map<String, dynamic>> ColKelas = firestore
  //       .collection('Sekolah')
  //       .doc(idSekolah)
  //       .collection('siswa')
  //       .doc(docIdSiswa)
  //       .collection('tahunajaran')
  //       .doc(idTahunAjaran)
  //       .collection('kelasnya');

  //   DocumentSnapshot<Map<String, dynamic>> docSnapKelas =
  //       await ColKelas.doc(idKelasnya).get();

  //   if (docSnapKelas.exists) {
  //     return docSnapKelas;
  //   } else {
  //     throw Exception('Siswa belum memiliki kelas');
  //   }
  // }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataInfo() async* {
    // ignore: unnecessary_null_comparison
    // if (idTahunAjaran == null) return const Stream.empty();

    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");

    yield* firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('tahunajaran')
        .doc(idTahunAjaran)
        .collection('informasisekolah')
        .orderBy('tanggalinput', descending: true)
        .snapshots();
  }

  Future<void> keDaftarNilai() async {
    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");
    // String kelasnya = data.toString();

    // print('semesternya(terakhir) = $semesternya');
    // print('docIdSiswa = $docIdSiswa');

    QuerySnapshot<Map<String, dynamic>> querySnapshotSiswa =
        await firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('siswa')
            .doc(docIdSiswa)
            .collection('tahunajarankelompok')
            .get();
    if (querySnapshotSiswa.docs.isNotEmpty) {
      Map<String, dynamic> dataSiswa = querySnapshotSiswa.docs.first.data();
      String faseNya = dataSiswa['fase'];

      // print('faseNya = $faseNya');

      QuerySnapshot<Map<String, dynamic>> querySnapshotSiswaAmbilPengampu =
          await firestore
              .collection('Sekolah')
              .doc(idSekolah)
              .collection('siswa')
              .doc(docIdSiswa)
              .collection('tahunajarankelompok')
              .doc(idTahunAjaran)
              // .collection('semester')
              // .doc(semesternya)
              .collection('kelompokmengaji')
              // .where('uid', isEqualTo: docIdSiswa)
              .get();
      if (querySnapshotSiswaAmbilPengampu.docs.isNotEmpty) {
        Map<String, dynamic> dataSiswaAmbilPengampu =
            querySnapshotSiswaAmbilPengampu.docs.first.data();
        String namaPengampuNya = dataSiswaAmbilPengampu['namapengampu'];
        String tempatmengajiNya = dataSiswaAmbilPengampu['tempatmengaji'];

        CollectionReference<Map<String, dynamic>> colSemester = firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('tahunajaran')
            .doc(idTahunAjaran)
            .collection('kelompokmengaji')
            .doc(faseNya)
            .collection('pengampu')
            .doc(namaPengampuNya)
            .collection('tempat')
            .doc(tempatmengajiNya)
            .collection('daftarsiswa')
            .doc(docIdSiswa)
            .collection('semester');

        QuerySnapshot<Map<String, dynamic>> snapSemester =
            await colSemester.get();

        if (snapSemester.docs.isNotEmpty) {
          Map<String, dynamic> dataSemester = snapSemester.docs.first.data();
          String namaSemester = dataSemester['namasemester'];

          DocumentSnapshot<Map<String, dynamic>> snapDaftarNilai =
              await firestore
                  .collection('Sekolah')
                  .doc(idSekolah)
                  .collection('tahunajaran')
                  .doc(idTahunAjaran)
                  // .collection('semester')
                  // .doc(semesternya)
                  .collection('kelompokmengaji')
                  .doc(faseNya)
                  .collection('pengampu')
                  .doc(namaPengampuNya)
                  .collection('tempat')
                  .doc(tempatmengajiNya)
                  .collection('daftarsiswa')
                  .doc(docIdSiswa)
                  .collection('semester')
                  .doc(namaSemester)
                  // .collection('nilai')
                  // .orderBy('tanggalinput', descending: true)
                  .get();

          print("snapDaftarNilai = $snapDaftarNilai");
          
          Get.toNamed(Routes.DAFTAR_NILAI_HALAQOH, arguments: snapDaftarNilai);
        } 
        else if (snapSemester.docs.isEmpty) {
          Get.toNamed(Routes.DAFTAR_NILAI_HALAQOH, arguments: null);
        }
      }
    }
    // throw Exception('No data found for the current student.');
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDataNilai() async {
    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");

    QuerySnapshot<Map<String, dynamic>> querySnapshotSiswaAmbilPengampu =
        await firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('siswa')
            .doc(docIdSiswa)
            .collection('tahunajarankelompok')
            .doc(idTahunAjaran)
            .collection('kelompokmengaji')
            // .where('uid', isEqualTo: docIdSiswa)
            .get();
    if (querySnapshotSiswaAmbilPengampu.docs.isNotEmpty) {
      Map<String, dynamic> dataSiswa =
          querySnapshotSiswaAmbilPengampu.docs.first.data();
      String faseNya = dataSiswa['fase'];
      String namaPengampuNya = dataSiswa['namapengampu'];
      String tempatmengajiNya = dataSiswa['tempatmengaji'];

      CollectionReference<Map<String, dynamic>> colSemester = firestore
          .collection('Sekolah')
          .doc(idSekolah)
          .collection('tahunajaran')
          .doc(idTahunAjaran)
          .collection('kelompokmengaji')
          .doc(faseNya)
          .collection('pengampu')
          .doc(namaPengampuNya)
          .collection('tempat')
          .doc(tempatmengajiNya)
          .collection('daftarsiswa')
          .doc(docIdSiswa)
          .collection('semester');

      QuerySnapshot<Map<String, dynamic>> snapSemester =
          await colSemester.get();
      if (snapSemester.docs.isNotEmpty) {
        Map<String, dynamic> dataSemester = snapSemester.docs.first.data();
        String namaSemester = dataSemester['namasemester'];

        // String kelasnya = data.toString();
        return await firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('tahunajaran')
            .doc(idTahunAjaran)
            .collection('kelompokmengaji')
            .doc(faseNya)
            .collection('pengampu')
            .doc(namaPengampuNya)
            .collection('tempat')
            .doc(tempatmengajiNya)
            .collection('daftarsiswa')
            .doc(docIdSiswa)
            .collection('semester')
            .doc(namaSemester)
            .collection('nilai')
            .orderBy('tanggalinput', descending: true)
            .get();
      } else {
        throw Exception('Semester data not found');
      }
    } else {
      throw Exception('Semester data not found');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataNilaiHalaqoh() async* {
    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");

    QuerySnapshot<Map<String, dynamic>> querySnapshotSiswaAmbilPengampu =
        await firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('siswa')
            .doc(docIdSiswa)
            .collection('tahunajarankelompok')
            .doc(idTahunAjaran)
            .collection('kelompokmengaji')
            // .where('uid', isEqualTo: docIdSiswa)
            .get();
    if (querySnapshotSiswaAmbilPengampu.docs.isNotEmpty) {
      Map<String, dynamic> dataSiswa =
          querySnapshotSiswaAmbilPengampu.docs.first.data();
      String faseNya = dataSiswa['fase'];
      String namaPengampuNya = dataSiswa['namapengampu'];
      String tempatmengajiNya = dataSiswa['tempatmengaji'];

      CollectionReference<Map<String, dynamic>> colSemester = firestore
          .collection('Sekolah')
          .doc(idSekolah)
          .collection('tahunajaran')
          .doc(idTahunAjaran)
          .collection('kelompokmengaji')
          .doc(faseNya)
          .collection('pengampu')
          .doc(namaPengampuNya)
          .collection('tempat')
          .doc(tempatmengajiNya)
          .collection('daftarsiswa')
          .doc(docIdSiswa)
          .collection('semester');

      QuerySnapshot<Map<String, dynamic>> snapSemester =
          await colSemester.get();
      if (snapSemester.docs.isNotEmpty) {
        Map<String, dynamic> dataSemester = snapSemester.docs.first.data();
        String namaSemester = dataSemester['namasemester'];

        // String kelasnya = data.toString();
        yield* firestore
            .collection('Sekolah')
            .doc(idSekolah)
            .collection('tahunajaran')
            .doc(idTahunAjaran)
            .collection('kelompokmengaji')
            .doc(faseNya)
            .collection('pengampu')
            .doc(namaPengampuNya)
            .collection('tempat')
            .doc(tempatmengajiNya)
            .collection('daftarsiswa')
            .doc(docIdSiswa)
            .collection('semester')
            .doc(namaSemester)
            .collection('nilai')
            .orderBy('tanggalinput', descending: true)
            .snapshots();
      } else {
        throw Exception('Semester data not found');
      }
    } else {
      throw Exception('Semester data not found');
    }
  }
}
