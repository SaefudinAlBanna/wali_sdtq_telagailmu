// lib/app/modules/halaqah_riwayat_siswa/views/halaqah_riwayat_siswa_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamRiwayat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada riwayat setoran.", style: TextStyle(fontSize: 16, color: Colors.grey)));
          }
          final riwayatList = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: riwayatList.length + 1, // +1 untuk header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildSummaryCard(riwayatList.length);
              }
              final setoran = HalaqahSetoranModel.fromFirestore(riwayatList[index - 1]);
              final setoranNumber = riwayatList.length - (index - 1);
              return _buildSetoranCard(setoran, setoranNumber);
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int total) {
    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        leading: const Icon(Icons.history_edu_rounded),
        title: const Text("Total Riwayat Setoran", style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(total.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSetoranCard(HalaqahSetoranModel setoran, int setoranNumber) {
    final bool isDinilaiOlehPengganti = setoran.isDinilaiPengganti && (setoran.namaPenilai != null && setoran.namaPenilai!.isNotEmpty);
    final String namaPemberiNilai = isDinilaiOlehPengganti ? setoran.namaPenilai! : setoran.namaPengampu;

    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text(setoranNumber.toString())),
        title: Text("Setoran ${DateFormat('dd MMMM yyyy').format(setoran.tanggalTugas.toDate())}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(setoran.status, style: TextStyle(color: setoran.status == 'Sudah Dinilai' ? Colors.green.shade700 : Colors.orange.shade800, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Detail Tugas"),
                _buildDetailRow("Sabak/Terbaru", setoran.tugas['sabak']),
                _buildDetailRow("Sabqi", setoran.tugas['sabqi']),
                _buildDetailRow("Manzil", setoran.tugas['manzil']),
                _buildDetailRow("Tambahan", setoran.tugas['tambahan']),
                const Divider(height: 24),
                _buildSectionTitle("Hasil Penilaian"),
                _buildDetailRow("Nilai Sabak", setoran.nilai['sabak']),
                _buildDetailRow("Nilai Sabqi", setoran.nilai['sabqi']),
                _buildDetailRow("Nilai Manzil", setoran.nilai['manzil']),
                _buildDetailRow("Nilai Tambahan", setoran.nilai['tambahan']),
                const Divider(height: 24),
                _buildSectionTitle("Catatan dari Pengampu: $namaPemberiNilai"),
                if (isDinilaiOlehPengganti)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("(Sebagai Pengganti)", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontSize: 12)),
                  ),
                _buildDetailRow(null, setoran.catatanPengampu),
                const Divider(height: 24),
                _buildSectionTitle("Catatan Anda untuk Pengampu"),
                _buildCatatanOrangTuaSection(setoran),
                if (setoran.status == 'Tugas Diberikan') ...[
                  const Divider(height: 24),
                  _buildAntrianSection(setoran),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntrianSection(HalaqahSetoranModel setoran) {
    bool sudahAntri = setoran.waktuAntri != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle("Antrian Setoran Besok"),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: sudahAntri ? null : () => controller.daftarAntrianSetoran(setoran),
          icon: Icon(sudahAntri ? Icons.check_circle : Icons.pan_tool_rounded),
          label: Text(sudahAntri ? "Anda Sudah Terdaftar" : "Daftar untuk Setoran"),
          style: ElevatedButton.styleFrom(
            backgroundColor: sudahAntri ? Colors.grey : Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: controller.streamAntrianGrup(setoran),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Daftar antrian akan muncul di sini.", style: TextStyle(color: Colors.grey));
            }
            final dataAntrian = snapshot.data!.data()?['antrianSetoran'] as Map<String, dynamic>? ?? {};
            if (dataAntrian.isEmpty) {
              return const Text("Jadilah yang pertama mendaftar!", style: TextStyle(color: Colors.grey));
            }
            final sortedAntrian = dataAntrian.entries.toList()..sort((a, b) => (a.value['waktu'] as Timestamp).compareTo(b.value['waktu'] as Timestamp));
            return Column(
              children: sortedAntrian.asMap().entries.map((entry) {
                int index = entry.key;
                var data = entry.value.value;
                bool isCurrentUser = entry.value.key == controller.authC.auth.currentUser!.uid;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(radius: 14, child: Text("${index + 1}")),
                  title: Text(data['nama'] ?? 'Siswa'),
                  trailing: isCurrentUser ? const Icon(Icons.arrow_back, color: Colors.blue) : null,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCatatanOrangTuaSection(HalaqahSetoranModel setoran) {
    if (setoran.catatanOrangTua.isNotEmpty) {
      // Jika catatan sudah ada, tampilkan sebagai teks
      return _buildDetailRow(null, setoran.catatanOrangTua);
    } else {
      // Jika kosong, tampilkan TextField dan tombol kirim
      final textController = TextEditingController();
      return Column(
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Tulis balasan atau catatan..."),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Obx(() => Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: controller.isSending.value ? null : () => controller.kirimCatatan(setoran.id, textController),
              icon: controller.isSending.value ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              label: const Text("Kirim"),
            ),
          )),
        ],
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildDetailRow(String? title, String? value) {
    final displayValue = (value != null && value.isNotEmpty) ? value : "-";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text("$title:", style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(displayValue, textAlign: title == null ? TextAlign.start : TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}