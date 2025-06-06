import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/daftar_mata_pelajaran_controller.dart';

class DaftarMataPelajaranView extends GetView<DaftarMataPelajaranController> {
  const DaftarMataPelajaranView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DaftarMataPelajaranView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DaftarMataPelajaranView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
