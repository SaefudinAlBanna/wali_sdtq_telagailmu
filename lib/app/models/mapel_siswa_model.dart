// lib/app/models/mapel_siswa_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MapelSiswaModel {
  final String id; // ID Mapel
  final String namaMapel;
  final String namaGuru;
  final String alias;
  final String idGuru;

  MapelSiswaModel({
    required this.id,
    required this.namaMapel,
    required this.namaGuru,
    required this.alias,
    required this.idGuru,
  });

  factory MapelSiswaModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MapelSiswaModel(
      id: doc.id,
      namaMapel: data['namaMapel'] ?? 'Tanpa Nama',
      namaGuru: data['namaGuru'] ?? 'Belum Ditentukan',
      alias: data['alias'] ?? data['namaGuru'] ?? 'N/A',
      idGuru: data['idGuru'] ?? '',
    );
  }
}