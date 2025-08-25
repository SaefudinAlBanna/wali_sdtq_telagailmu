// lib/app/models/halaqah_setoran_model.dart (Aplikasi ORANG TUA)

import 'package:cloud_firestore/cloud_firestore.dart';

class HalaqahSetoranModel {
  final String id;
  final String status;
  final Timestamp tanggalTugas;
  final Timestamp? tanggalDinilai;
  final Map<String, dynamic> tugas;
  final Map<String, dynamic> nilai;
  final String catatanPengampu;
  final String catatanOrangTua;
  final String namaPengampu;
  final String? namaPenilai;
  final bool isDinilaiPengganti;
  // --- [FIX] Tambahkan field yang hilang ---
  final String idGrup;
  final String tahunAjaran;
  final Timestamp? waktuAntri;

  HalaqahSetoranModel({
    required this.id, required this.status, required this.tanggalTugas,
    this.tanggalDinilai, required this.tugas, required this.nilai,
    required this.catatanPengampu, required this.catatanOrangTua,
    required this.namaPengampu, this.namaPenilai, required this.isDinilaiPengganti,
    // --- [FIX] Tambahkan di konstruktor ---
    required this.idGrup, required this.tahunAjaran, this.waktuAntri,
  });

  factory HalaqahSetoranModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return HalaqahSetoranModel(
      id: doc.id,
      status: data['status'] ?? 'Selesai',
      tanggalTugas: data['tanggalTugas'] ?? Timestamp.now(),
      tanggalDinilai: data['tanggalDinilai'],
      tugas: Map<String, dynamic>.from(data['tugas'] ?? {}),
      nilai: Map<String, dynamic>.from(data['nilai'] ?? {}),
      catatanPengampu: data['catatanPengampu'] ?? '',
      catatanOrangTua: data['catatanOrangTua'] ?? '',
      namaPengampu: data['namaPengampu'] ?? 'N/A',
      namaPenilai: data['namaPenilai'],
      isDinilaiPengganti: data['isDinilaiPengganti'] ?? false,
      // --- [FIX] Ambil data dari Firestore ---
      idGrup: data['idGrup'] ?? '',
      tahunAjaran: data['tahunAjaran'] ?? '',
      waktuAntri: data['waktuAntri'],
    );
  }
}