import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/jadwal_pelajaran_controller.dart';

class JadwalPelajaranView extends GetView<JadwalPelajaranController> {
  const JadwalPelajaranView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JadwalPelajaranView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'JadwalPelajaranView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
