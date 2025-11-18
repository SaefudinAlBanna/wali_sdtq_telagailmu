// lib/app/modules/halaqah_riwayat_siswa/views/halaqah_riwayat_siswa_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/halaqah_utils.dart';
import '../../../models/halaqah_setoran_model.dart';
import '../controllers/halaqah_riwayat_siswa_controller.dart';

class HalaqahRiwayatSiswaView extends GetView<HalaqahRiwayatSiswaController> {
  const HalaqahRiwayatSiswaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Halaqah'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: _buildTahunAjaranDropdown(),
        ),
      ),
      body: Column(
        children: [
          _buildInfoTingkatanCard(),
          // [DIHAPUS] Kartu info pengampu tidak lagi di sini.
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: controller.tabController,
              tabs: controller.daftarSemester.map((sem) => Tab(text: "Semester $sem")).toList(),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GetBuilder<HalaqahRiwayatSiswaController>(
              builder: (ctrl) {
                return TabBarView(
                  controller: ctrl.tabController,
                  children: ctrl.daftarSemester.map((semesterTab) {
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: ctrl.streamRiwayat(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildInfoMessage(
                            icon: Icons.inbox_rounded,
                            message: "Belum ada riwayat setoran untuk periode ini.",
                          );
                        }
                        
                        final riwayatList = snapshot.data!.docs;

                        // [PERBAIKAN KUNCI] Ambil data pengampu dari sumber data yang PASTI BENAR:
                        // yaitu dari dokumen setoran pertama di daftar.
                        final firstSetoranData = HalaqahSetoranModel.fromFirestore(riwayatList.first);
                        final aliasPengampu = firstSetoranData.aliasPengampu;
                        final namaPengampu = firstSetoranData.namaPengampu;
                        final displayName = (aliasPengampu != null && aliasPengampu.isNotEmpty) ? aliasPengampu : namaPengampu;
                        
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: riwayatList.length + 1, // +1 untuk kartu info pengampu
                          itemBuilder: (context, index) {
                            // Item pertama adalah kartu info pengampu yang baru
                            if (index == 0) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.teal.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.teal.withOpacity(0.05),
                                child: ListTile(
                                  leading: Icon(Icons.person, color: Colors.teal.shade700),
                                  title: const Text("Pengampu Halaqah Periode Ini"),
                                  subtitle: Text(
                                    displayName,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal.shade700),
                                  ),
                                ),
                              );
                            }
                            
                            // Item selanjutnya adalah kartu setoran, sesuaikan index
                            final setoran = HalaqahSetoranModel.fromFirestore(riwayatList[index - 1]);
                            return _buildSetoranCard(context, setoran);
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET AppBar & Filter
  Widget _buildTahunAjaranDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(Get.context!).scaffoldBackgroundColor,
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: controller.selectedTahunAjaran.value.isEmpty ? null : controller.selectedTahunAjaran.value,
          hint: const Text("Pilih Tahun Ajaran"),
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: controller.daftarTahunAjaran
              .map((ta) => DropdownMenuItem(value: ta, child: Text(ta)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedTahunAjaran.value = value;
              controller.checkIfSiswaHasHalaqahGroup();
              controller.update();
            }
          },
        ),
      ),
    );
  }

  // WIDGET KONTEN UTAMA
  Widget _buildInfoTingkatanCard() {
    final tingkatanData = controller.configC.infoUser['halaqahTingkatan'] as Map<String, dynamic>?;
    final namaTingkatan = tingkatanData?['nama'] as String? ?? 'Belum Diatur';
    final warna = HalaqahUtils.getWarnaTingkatan(namaTingkatan);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: warna.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      color: warna.withOpacity(0.05),
      child: ListTile(
        leading: Icon(Icons.bookmark, color: warna),
        title: const Text("Tingkatan Halaqah"),
        subtitle: Text(
          namaTingkatan,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: warna),
        ),
      ),
    );
  }

  Widget _buildSetoranCard(BuildContext context, HalaqahSetoranModel setoran) {
    final bool isDinilai = setoran.status == 'Sudah Dinilai';
    final tglSetoran = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(setoran.tanggalTugas.toDate());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(tglSetoran, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Chip(
            label: Text(setoran.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: isDinilai ? Colors.green.shade600 : Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            labelPadding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTugasDanNilaiSection(setoran),
                const Divider(height: 32),
                _buildCatatanPengampuSection(setoran),
                const SizedBox(height: 16),
                _buildCatatanOrangTuaSection(setoran),
                if (setoran.status == 'Tugas Diberikan' && setoran.tahunAjaran == controller.configC.tahunAjaranAktif.value && setoran.semester == controller.configC.semesterAktif.value) ...[
                  const Divider(height: 32),
                  _buildAntrianSection(setoran),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET DETAIL DALAM KARTU
  Widget _buildTugasDanNilaiSection(HalaqahSetoranModel setoran) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(icon: Icons.assignment_outlined, title: "Detail Tugas"),
              // Gunakan widget baru di sini
              _buildStructuredDetailItem("Sabak/Baru", setoran.tugas['sabak']),
              _buildStructuredDetailItem("Sabqi", setoran.tugas['sabqi']),
              _buildStructuredDetailItem("Manzil", setoran.tugas['manzil']),
              _buildStructuredDetailItem("Tambahan", setoran.tugas['tambahan']),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(icon: Icons.star_border_rounded, title: "Hasil Nilai"),
              // Dan juga di sini
              _buildStructuredDetailItem("Sabak/Baru", setoran.nilai['sabak']),
              _buildStructuredDetailItem("Sabqi", setoran.nilai['sabqi']),
              _buildStructuredDetailItem("Manzil", setoran.nilai['manzil']),
              _buildStructuredDetailItem("Tambahan", setoran.nilai['tambahan']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStructuredDetailItem(String title, String? value) {
    final displayValue = (value != null && value.isNotEmpty) ? value : "-";

    // Cek apakah value memiliki format Juz dan Surah
    final parts = displayValue.contains(',') ? displayValue.split(',') : [displayValue];
    final part1 = parts[0].trim();
    final part2 = parts.length > 1 ? parts.sublist(1).join(',').trim() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title:", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  part1,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (part2 != null)
                  Text(
                    part2,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey.shade800),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanPengampuSection(HalaqahSetoranModel setoran) {
    // Logika ini sekarang 100% benar karena model sudah menerima data yang lengkap.
    String namaPemberiNilai;
    if (setoran.isDinilaiPengganti && setoran.namaPenilai != null && setoran.namaPenilai!.isNotEmpty) {
      namaPemberiNilai = setoran.namaPenilai!;
    } else if (setoran.aliasPengampu != null && setoran.aliasPengampu!.isNotEmpty) {
      namaPemberiNilai = setoran.aliasPengampu!;
    } else {
      namaPemberiNilai = setoran.namaPengampu;
    }
    final String catatan = setoran.catatanPengampu.isNotEmpty ? setoran.catatanPengampu : "Tidak ada catatan.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(icon: Icons.edit_note_rounded, title: "Catatan dari: $namaPemberiNilai"),
        if (setoran.isDinilaiPengganti && (setoran.namaPenilai != null && setoran.namaPenilai!.isNotEmpty))
          Text(
            "(Sebagai Pengganti)",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontSize: 12),
          ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(catatan, style: TextStyle(color: Colors.grey.shade800)),
        ),
      ],
    );
  }

  Widget _buildCatatanOrangTuaSection(HalaqahSetoranModel setoran) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(icon: Icons.chat_bubble_outline_rounded, title: "Catatan Anda untuk Pengampu"),
        const SizedBox(height: 8),
        if (setoran.catatanOrangTua.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(setoran.catatanOrangTua, style: TextStyle(color: Colors.blue.shade800)),
          )
        else
          _buildFormKirimCatatan(setoran),
      ],
    );
  }
  
  Widget _buildFormKirimCatatan(HalaqahSetoranModel setoran) {
    final textController = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Tulis balasan atau catatan di sini...",
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        Obx(() => Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: controller.isSending.value ? null : () => controller.kirimCatatan(setoran.id, textController),
                icon: controller.isSending.value ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Icon(Icons.send),
                label: const Text("Kirim"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildAntrianSection(HalaqahSetoranModel setoran) {
    bool sudahAntri = setoran.waktuAntri != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(icon: Icons.list_alt_rounded, title: "Antrian Setoran"),
        const SizedBox(height: 8),
        Text(
          "Jika Ananda berhalangan hadir esok hari, tidak perlu mendaftar antrian.",
          style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: sudahAntri ? null : () => controller.daftarAntrianSetoran(setoran),
          icon: Icon(sudahAntri ? Icons.check_circle_outline_rounded : Icons.pan_tool_outlined),
          label: Text(sudahAntri ? "Anda Sudah Terdaftar" : "Daftar untuk Setoran Esok Hari"),
          style: ElevatedButton.styleFrom(
            backgroundColor: sudahAntri ? Colors.grey : Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: controller.streamAntrianGrup(setoran),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const SizedBox.shrink();
            }
            final dataAntrian = snapshot.data!.data()?['antrianSetoran'] as Map<String, dynamic>? ?? {};
            if (dataAntrian.isEmpty) {
              return const Center(child: Text("Jadilah yang pertama mendaftar!", style: TextStyle(color: Colors.grey)));
            }
            final sortedAntrian = dataAntrian.entries.toList()..sort((a, b) => (a.value['waktu'] as Timestamp).compareTo(b.value['waktu'] as Timestamp));
            
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: sortedAntrian.asMap().entries.map((entry) {
                  int index = entry.key;
                  var data = entry.value.value;
                  bool isCurrentUser = entry.value.key == controller.authC.auth.currentUser!.uid;
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(radius: 14, child: Text("${index + 1}")),
                    title: Text(data['nama'] ?? 'Siswa', style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal)),
                    tileColor: isCurrentUser ? Colors.teal.withOpacity(0.1) : null,
                    trailing: isCurrentUser ? const Chip(label: Text("Anda"), padding: EdgeInsets.zero) : null,
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  // WIDGET HELPERS
  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Agar ikon tetap di atas jika judul multi-baris
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          // [PERBAIKAN] Bungkus dengan Expanded agar tidak overflow jika judulnya panjang
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoMessage({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}