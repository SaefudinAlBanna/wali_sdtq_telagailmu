// Di aplikasi ORANG TUA: lib/app/modules/detail_rapor/views/detail_rapor_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/rapor_model.dart';
import '../controllers/detail_rapor_controller.dart';

class DetailRaporView extends GetView<DetailRaporController> {
  const DetailRaporView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Rapor Digital'),
      ),
      body: Obx(() {
        // Jika data rapor tidak ada (karena error argumen), tampilkan pesan
        if (controller.rapor.value == null) {
          return const Center(child: Text("Data rapor tidak tersedia."));
        }
        // Jika ada, tampilkan datanya menggunakan widget yang kita "pinjam"
        return _buildRaporDisplay(controller.rapor.value!);
      }),
    );
  }

  // SEMUA WIDGET DI BAWAH INI ADALAH SALINAN LANGSUNG DARI APLIKASI GURU
  // (RaporSiswaView), DENGAN SEDIKIT PENYESUAIAN.

  Widget _buildRaporDisplay(RaporModel rapor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeader(rapor),
        const SizedBox(height: 16),
        _buildNilaiAkademikSection(rapor.daftarNilaiMapel),
        const SizedBox(height: 16),
        _buildPengembanganDiriSection(rapor.dataHalaqah, rapor.daftarEkskul),
        const SizedBox(height: 16),
        _buildAbsensiSection(rapor.rekapAbsensi),
        const SizedBox(height: 16),
        _buildCatatanWaliKelasSection(rapor),
      ],
    );
  }

  Widget _buildHeader(RaporModel rapor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(rapor.namaSiswa, style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text("NISN: ${rapor.nisn}"),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _headerInfo("Kelas", rapor.idKelas.split('_').first),
                _headerInfo("Semester", rapor.semester),
                _headerInfo("Tahun Ajaran", rapor.idTahunAjaran.replaceAll('-', '/')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildNilaiAkademikSection(List<NilaiMapelRapor> daftarNilai) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A. Nilai Akademik", style: Get.textTheme.titleLarge),
            const Divider(),
            if (daftarNilai.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text("Data nilai belum tersedia.")),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daftarNilai.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final nilai = daftarNilai[index];
                  return ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(nilai.namaMapel, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Text(
                      nilai.nilaiAkhir.toStringAsFixed(1),
                      style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16).copyWith(top: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Guru: ${nilai.namaGuru}", style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 8),
                            const Text("Capaian Kompetensi:", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(nilai.deskripsiCapaian, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengembanganDiriSection(DataHalaqahRapor dataHalaqah, List<DataEkskulRapor> daftarEkskul) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("B. Pengembangan Diri", style: Get.textTheme.titleLarge),
            const Divider(),
            
            // --- [MODIFIKASI TOTAL BAGIAN HALAQAH] ---
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text("Halaqah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              // Tampilkan Nilai Akhir di trailing jika ada
              trailing: dataHalaqah.nilaiAkhir != null 
                ? Chip(
                    label: Text(dataHalaqah.nilaiAkhir.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    backgroundColor: Colors.indigo,
                    avatar: const Icon(Icons.star, color: Colors.white, size: 16),
                  )
                : null,
            ),
            const SizedBox(height: 8),
            _buildHalaqahInfoRow(Icons.bookmark_border, "Tingkatan", dataHalaqah.tingkatan),
            const SizedBox(height: 8),
            _buildHalaqahInfoRow(Icons.menu_book_outlined, "Pencapaian", dataHalaqah.pencapaian),
            const SizedBox(height: 12),
            // Tampilkan Catatan Pengampu jika ada
            if(dataHalaqah.catatan.isNotEmpty && dataHalaqah.catatan != 'Belum ada catatan akhir dari pengampu.') ...[
              const Text("Catatan Pengampu:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(dataHalaqah.catatan, style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ],
            // --- [AKHIR MODIFIKASI HALAQAH] ---

            const Divider(height: 24),
            const ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              title: Text("Ekstrakurikuler", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (daftarEkskul.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Text("Tidak mengikuti ekstrakurikuler semester ini.", style: TextStyle(color: Colors.grey)),
              )
            else
              ...daftarEkskul.map((ekskul) => ListTile(
                    leading: const SizedBox(),
                    title: Text(ekskul.namaEkskul),
                    subtitle: Text(ekskul.catatan),
                    trailing: Text(ekskul.nilai, style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildHalaqahInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 12),
        Text("$label: ", style: TextStyle(color: Colors.grey.shade700)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildAbsensiSection(RekapAbsensi rekap) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("C. Ketidakhadiran", style: Get.textTheme.titleLarge),
            const Divider(),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _absenItem("Sakit", rekap.sakit),
                  const VerticalDivider(),
                  _absenItem("Izin", rekap.izin),
                  const VerticalDivider(),
                  _absenItem("Tanpa Keterangan", rekap.alpa),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _absenItem(String label, int jumlah) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(jumlah.toString(), style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget _buildCatatanWaliKelasSection(RaporModel rapor) { // Menerima seluruh objek rapor
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("D. Catatan Wali Kelas", style: Get.textTheme.titleLarge),
  //           const Divider(),
  //           const SizedBox(height: 8),
  //           Text(rapor.catatanWaliKelas), // Ambil catatan dari rapor
  //           const SizedBox(height: 24),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: const [
  //               Text("Wali Kelas,"),
  //               Text("Orang Tua/Wali,"),
  //             ],
  //           ),
  //           const SizedBox(height: 64),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               // --- [PERBAIKAN KUNCI] ---
  //               // Ambil nama Wali Kelas langsung dari data RaporModel, bukan dari ConfigController.
  //               Text("(${rapor.namaWaliKelas})", style: const TextStyle(fontWeight: FontWeight.bold)),

  //               // Ambil nama Orang Tua langsung dari data RaporModel
  //               Text("(${rapor.namaOrangTua})"),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCatatanWaliKelasSection(RaporModel rapor) { // Pastikan menerima RaporModel
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("D. Catatan Wali Kelas", style: Get.textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 8),
            Text(rapor.catatanWaliKelas), // Ambil catatan dari model
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Wali Kelas,"),
                const Text("Orang Tua/Wali,"),
              ],
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // [PERBAIKAN KUNCI] Ambil nama wali kelas dari model rapor
                Text("(${rapor.namaWaliKelas})", style: const TextStyle(fontWeight: FontWeight.bold)),
                
                // [PERBAIKAN KUNCI] Ambil nama orang tua dari model rapor
                Text("(${rapor.namaOrangTua})", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}