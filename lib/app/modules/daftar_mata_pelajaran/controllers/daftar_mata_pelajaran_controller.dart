// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DaftarMataPelajaranController extends GetxController {
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


  Future<QuerySnapshot<Map<String, dynamic>>> getDataMapel() async {
    String tahunajaranya = await getTahunAjaranTerakhir();
    String idTahunAjaran = tahunajaranya.replaceAll("/", "-");

    // String semester = await getSemesterTerakhir();

    // CollectionReference<Map<String, dynamic>> colSemester = firestore
    //     .collection('Sekolah')
    //     .doc(idSekolah)
    //     .collection('tahunajaran')
    //     .doc(idTahunAjaran)
    //     .collection('kelompokmengaji')
    //     .doc(dataNilai['fase'])
    //     .collection('pengampu')
    //     .doc(dataNilai['namapengampu'])
    //     // .collection('tempat')
    //     // .doc(dataNilai['tempatmengaji'])
    //     .collection('daftarsiswa')
    //     .doc(dataNilai['nisn'])
    //     .collection('semester');

    // QuerySnapshot<Map<String, dynamic>> snapSemester = await colSemester.get();
    // if (snapSemester.docs.isNotEmpty) {
    //   Map<String, dynamic> dataSemester = snapSemester.docs.first.data();
    //   String namaSemester = dataSemester['namasemester'];

      
      return await firestore
          .collection('Sekolah')
          .doc(idSekolah)
          .collection('tahunajaran')
          .doc(idTahunAjaran)
          .collection('kelasmapel')
          .doc(dataArgumen[0]['namakelas'])
          .collection('matapelajaran')
          .get();
    // } else {
    //   throw Exception('Semester data not found');
    // }
  }

}
