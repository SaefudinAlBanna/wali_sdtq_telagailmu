import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TagihanModel {
  final String id;
  final String deskripsi;
  final String jenisPembayaran;
  final int jumlahTagihan;
  final int jumlahTerbayar;
  final String status;
  final Timestamp? tanggalJatuhTempo;
  final bool isTunggakan;
  final Map<String, dynamic> metadata;
  final String? kelasSaatDitagih; // [BARU] Tambahkan properti ini

  TagihanModel({
    required this.id,
    required this.deskripsi,
    required this.jenisPembayaran,
    required this.jumlahTagihan,
    required this.jumlahTerbayar,
    required this.status,
    this.tanggalJatuhTempo,
    required this.isTunggakan,
    required this.metadata,
    this.kelasSaatDitagih, // [BARU] Tambahkan ke constructor
  });

  factory TagihanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TagihanModel(
      id: doc.id,
      deskripsi: data['deskripsi'] ?? 'Tanpa Deskripsi',
      jenisPembayaran: data['jenisPembayaran'] ?? 'Lainnya',
      jumlahTagihan: (data['jumlahTagihan'] as num?)?.toInt() ?? 0,
      jumlahTerbayar: (data['jumlahTerbayar'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'Belum Lunas',
      tanggalJatuhTempo: data['tanggalJatuhTempo'],
      isTunggakan: data['isTunggakan'] ?? false,
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      // [BARU] Baca field dari level atas
      kelasSaatDitagih: data['kelasSaatDitagih'] as String?,
    );
  }

  int get sisaTagihan => jumlahTagihan - jumlahTerbayar;

  String get bulanTahunSPP {
    if (jenisPembayaran == 'SPP' && metadata.containsKey('bulan') && metadata.containsKey('tahun')) {
      return DateFormat('MMMM yyyy', 'id_ID').format(DateTime(metadata['tahun'], metadata['bulan']));
    }
    return deskripsi;
  }
}