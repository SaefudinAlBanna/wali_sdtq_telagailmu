// lib/app/models/halaqah_setoran_model.dart (Pastikan model ini memiliki field yang diperlukan)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Import material untuk Color

class HalaqahSetoranModel {
  final String id;
  final String idPengampu;
  final String namaPengampu;
  final String? aliasPengampu; // Untuk tampilan alias
  final String idGrup; // [PERBAIKAN] Pastikan ada idGrup
  final String tahunAjaran; // [PERBAIKAN] Pastikan ada tahunAjaran
  final String semester;
  final String status; // Contoh: 'Tugas Diberikan', 'Menunggu Penilaian', 'Sudah Dinilai'
  final Map<String, dynamic> tugas; // {'sabak': 'Al-Baqarah 1-5', 'sabqi': 'Al-Fatihah', 'manzil': 'An-Nas'}
  final Map<String, dynamic> nilai; // {'sabak': 90, 'sabqi': 85, 'manzil': 95, 'tambahan': 0}
  final String catatanPengampu;
  final String catatanOrangTua;
  final Timestamp tanggalTugas;
  final Timestamp? waktuAntri; // Waktu siswa/ortu mendaftar antrian setoran
  final bool isDinilaiPengganti;
  final String? namaPenilai; // Nama guru pengganti jika ada

  HalaqahSetoranModel({
    required this.id,
    required this.idPengampu,
    required this.namaPengampu,
    this.aliasPengampu,
    required this.idGrup,
    required this.tahunAjaran,
    required this.semester,
    required this.status,
    required this.tugas,
    required this.nilai,
    required this.catatanPengampu,
    required this.catatanOrangTua,
    required this.tanggalTugas,
    this.waktuAntri,
    this.isDinilaiPengganti = false,
    this.namaPenilai,
  });

  factory HalaqahSetoranModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return HalaqahSetoranModel(
      id: doc.id,
      idPengampu: data['idPengampu'] ?? '',
      namaPengampu: data['namaPengampu'] ?? 'N/A',
      aliasPengampu: data['aliasPengampu'] as String?,
      idGrup: data['idGrup'] ?? '', // [PERBAIKAN] Ambil idGrup dari Firestore
      tahunAjaran: data['tahunAjaran'] ?? '', // [PERBAIKAN] Ambil tahunAjaran dari Firestore
      semester: data['semester'] ?? '',
      status: data['status'] ?? 'Tugas Diberikan',
      tugas: Map<String, dynamic>.from(data['tugas'] ?? {}),
      nilai: Map<String, dynamic>.from(data['nilai'] ?? {}),
      catatanPengampu: data['catatanPengampu'] ?? '',
      catatanOrangTua: data['catatanOrangTua'] ?? '',
      tanggalTugas: data['tanggalTugas'] ?? Timestamp.now(),
      waktuAntri: data['waktuAntri'] as Timestamp?,
      isDinilaiPengganti: data['isDinilaiPengganti'] ?? false,
      namaPenilai: data['namaPenilai'] as String?,
    );
  }

  String get namaPemberiNilai {
    // Prioritas 1: Jika dinilai oleh pengganti, gunakan nama penilai.
    if (isDinilaiPengganti && namaPenilai != null && namaPenilai!.isNotEmpty) {
      return namaPenilai!;
    }
    // Prioritas 2: Jika ada alias pengampu, gunakan alias.
    if (aliasPengampu != null && aliasPengampu!.isNotEmpty) {
      return aliasPengampu!;
    }
    // Prioritas 3: Jika tidak ada keduanya, gunakan nama pengampu lengkap.
    return namaPengampu;
  }

  // Tambahan helper untuk menghitung total nilai (opsional)
  int getTotalNilai() {
    return (nilai['sabak'] ?? 0) + (nilai['sabqi'] ?? 0) + (nilai['manzil'] ?? 0) + (nilai['tambahan'] ?? 0);
  }
}