import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/jadwal_pelajaran_controller.dart';

class JadwalPelajaranView extends GetView<JadwalPelajaranController> {
   JadwalPelajaranView({super.key});

   final dataArgumen = Get.arguments;

  @override
  Widget build(BuildContext context) {
    print("dataArgumen = ${dataArgumen[0]['namakelas']}");
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
