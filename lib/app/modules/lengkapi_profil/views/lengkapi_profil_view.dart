import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lengkapi_profil_controller.dart';

class LengkapiProfilView extends GetView<LengkapiProfilController> {
  const LengkapiProfilView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil Siswa'),
        automaticallyImplyLeading: false, // Mencegah pengguna kembali
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- KARTU DATA SISWA ---
              _buildSectionCard(
                title: "Data Pribadi Siswa",
                children: [
                  TextFormField(
                    controller: controller.namaPanggilanC,
                    decoration: const InputDecoration(labelText: "Nama Panggilan"),
                    validator: (v) => controller.validator(v, 'Nama Panggilan'),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.jenisKelamin.value,
                        decoration: const InputDecoration(labelText: "Jenis Kelamin"),
                        items: const [
                          DropdownMenuItem(value: "Laki-Laki", child: Text("Laki-Laki")),
                          DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
                        ],
                        onChanged: (v) => controller.jenisKelamin.value = v!,
                        validator: (v) => controller.validator(v, 'Jenis Kelamin'),
                      )),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.tempatLahirC,
                    decoration: const InputDecoration(labelText: "Tempat Lahir"),
                    validator: (v) => controller.validator(v, 'Tempat Lahir'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.tanggalLahirC,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Tanggal Lahir",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => controller.pilihTanggal(context),
                      ),
                    ),
                    validator: (v) => controller.validator(v, 'Tanggal Lahir'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- KARTU DATA ORANG TUA ---
              _buildSectionCard(
                title: "Data Orang Tua & Alamat",
                children: [
                  TextFormField(
                    controller: controller.namaAyahC,
                    decoration: const InputDecoration(labelText: "Nama Ayah"),
                    validator: (v) => controller.validator(v, 'Nama Ayah'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.noHpAyahC,
                    decoration: const InputDecoration(labelText: "No. HP Ayah"),
                    keyboardType: TextInputType.phone,
                    validator: (v) => controller.validator(v, 'No. HP Ayah'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.namaIbuC,
                    decoration: const InputDecoration(labelText: "Nama Ibu"),
                    validator: (v) => controller.validator(v, 'Nama Ibu'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.noHpIbuC,
                    decoration: const InputDecoration(labelText: "No. HP Ibu"),
                    keyboardType: TextInputType.phone,
                    validator: (v) => controller.validator(v, 'No. HP Ibu'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.alamatC,
                    decoration: const InputDecoration(labelText: "Alamat Lengkap", alignLabelWithHint: true),
                    maxLines: 3,
                    validator: (v) => controller.validator(v, 'Alamat'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- TOMBOL SIMPAN ---
              Obx(() => ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: controller.isLoading.value ? null : controller.simpanProfil,
                    icon: controller.isLoading.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded),
                    label: Text(controller.isLoading.value ? 'MENYIMPAN...' : 'SELESAI & SIMPAN PROFIL'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk membuat Card yang konsisten
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}