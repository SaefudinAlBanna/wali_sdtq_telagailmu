// Di aplikasi ORANG TUA: lib/app/modules/riwayat_rapor/views/riwayat_rapor_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/rapor_model.dart';
import '../controllers/riwayat_rapor_controller.dart';

class RiwayatRaporView extends GetView<RiwayatRaporController> {
  const RiwayatRaporView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Rapor Digital')),
      body: StreamBuilder<List<RaporModel>>(
        stream: controller.streamRiwayatRapor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("### FATAL ERROR - RIWAYAT RAPOR ### ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
            
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("Belum ada riwayat rapor yang dibagikan oleh Wali Kelas.", textAlign: TextAlign.center),
              ),
            );
          }
          final daftarRapor = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daftarRapor.length,
            itemBuilder: (context, index) {
              final rapor = daftarRapor[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.history_edu_rounded),
                  title: Text("Rapor Semester ${rapor.semester}"),
                  subtitle: Text("Tahun Ajaran ${rapor.idTahunAjaran.replaceAll('-', '/')}\nDibagikan pada: ${DateFormat('dd MMM yyyy').format(rapor.tanggalGenerate)}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => controller.goToDetailRapor(rapor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}