import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/jadwal_agis_controller.dart';

class JadwalAgisView extends GetView<JadwalAgisController> {
   JadwalAgisView({super.key});

  final dataArgumen = Get.arguments;

  @override
  Widget build(BuildContext context) {
    print("dataArgumen = ${dataArgumen[0]['namakelas']}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('JadwalAgisView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'JadwalAgisView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
