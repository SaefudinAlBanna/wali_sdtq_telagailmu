import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DaftarSppController extends GetxController {
  var dataArgumen = Get.arguments;

  String? idTahunAjaran;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String idUser = FirebaseAuth.instance.currentUser!.uid;
  String idSekolah = "P9984539";
  // String emailAdmin = FirebaseAuth.instance.currentUser!.email!;

   @override
  void onInit() async {
    super.onInit();
    String tahunajaranya = await getTahunAjaranTerakhir();
    idTahunAjaran = tahunajaranya.replaceAll("/", "-");
    // update();
  }

  Future<String> getTahunAjaranTerakhir() async {
    // Pastikan idSekolah sudah terinisialisasi
    if (idSekolah.isEmpty) { // Contoh validasi sederhana
      print("Error: idSekolah belum diatur");
      return Future.error("idSekolah belum diatur");
    }
    CollectionReference<Map<String, dynamic>> colTahunAjaran = firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('tahunajaran');
    QuerySnapshot<Map<String, dynamic>> snapshotTahunAjaran =
    await colTahunAjaran.orderBy('namatahunajaran', descending: false).get(); // Order untuk ambil yg terakhir
    
    if (snapshotTahunAjaran.docs.isEmpty) {
      return Future.error("Tidak ada data tahun ajaran");
    }
    
    List<Map<String, dynamic>> listTahunAjaran =
    snapshotTahunAjaran.docs.map((e) => e.data()).toList();
    String tahunAjaranTerakhir =
    listTahunAjaran.map((e) => e['namatahunajaran'] as String).toList().last;
    return tahunAjaranTerakhir;
  }

  Future<String> getSemesterTerakhir() async {
    // Pastikan idSekolah sudah terinisialisasi
    if (idTahunAjaran == null || idTahunAjaran!.isEmpty) {
      String tahunajaranya = await getTahunAjaranTerakhir();
      idTahunAjaran = tahunajaranya.replaceAll("/", "-");
    }
    CollectionReference<Map<String, dynamic>> colTahunAjaran = firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('tahunajaran')
        .doc(idTahunAjaran)
        .collection('semester');
    QuerySnapshot<Map<String, dynamic>> snapshotSemester =
    await colTahunAjaran.orderBy('namasemester', descending: false).get(); // Order untuk ambil yg terakhir
    
    if (snapshotSemester.docs.isEmpty) {
      return Future.error("Tidak ada data Semester");
    }
    
    List<Map<String, dynamic>> listSemester =
    snapshotSemester.docs.map((e) => e.data()).toList();
    String tahunSemesterTerakhir =
    listSemester.map((e) => e['namasemester'] as String).toList().last;
    return tahunSemesterTerakhir;
  }


  Future<QuerySnapshot<Map<String, dynamic>>> getDataSPP() async {
    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");

    // String semester = await getSemesterTerakhir();

    // CollectionReference<Map<String, dynamic>> colPengampu = firestore
    //     .collection('Sekolah')
    //     .doc(idSekolah)
    //     .collection('siswa')
    //     .doc(dataArgumen[0]['nisn'])
    //     .collection('tahunajarankelompok')
    //     .doc(idTahunAjaran)
    //     .collection('kelompokmengaji')
    //     .doc(dataArgumen[0]['fase'])
    //     .collection('pengampu');

    // QuerySnapshot<Map<String, dynamic>> snapPengampu = await colPengampu.get();
    // if (snapPengampu.docs.isNotEmpty) {
    //   Map<String, dynamic> dataPengampu = snapPengampu.docs.first.data();
    //   String namapengampu = dataPengampu['namapengampu'];
    //   print("namapengampu = $namapengampu");

      
      return await firestore
          .collection('Sekolah')
          .doc(idSekolah)
          .collection('tahunajaran')
          .doc(idTahunAjaran)
          .collection('kelastahunajaran')
          .doc(dataArgumen[0]['namakelas'])
          .collection('daftarsiswa')
          .doc(dataArgumen[0]['nisn'])
          .collection('SPP')
          .orderBy('tglbayar', descending: true)
          .get();
    // } else {
    //   throw Exception('Semester data not found');
    // }
  }

  void test() async {
    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");

    String semester = await getSemesterTerakhir();

    CollectionReference<Map<String, dynamic>> colPengampu = firestore
        .collection('Sekolah')
        .doc(idSekolah)
        .collection('siswa')
        .doc(dataArgumen[0]['nisn'])
        .collection('tahunajarankelompok')
        .doc(idTahunAjaran)
        .collection('kelompokmengaji')
        .doc(dataArgumen['fase'])
        .collection('pengampu');

    QuerySnapshot<Map<String, dynamic>> snapPengampu = await colPengampu.get();
    if (snapPengampu.docs.isNotEmpty) {
      Map<String, dynamic> dataPengampu = snapPengampu.docs.first.data();
      String namapengampu = dataPengampu['namapengampu'];

      print("namapengampu = $namapengampu");
      print("semester = $semester");
      print("fase = ${dataArgumen[0]['fase']}");
  }
  }

}