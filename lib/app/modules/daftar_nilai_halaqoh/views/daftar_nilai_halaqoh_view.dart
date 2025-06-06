import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/daftar_nilai_halaqoh_controller.dart';

class DaftarNilaiHalaqohView extends GetView<DaftarNilaiHalaqohController> {
  const DaftarNilaiHalaqohView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DaftarNilaiHalaqohView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DaftarNilaiHalaqohView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
