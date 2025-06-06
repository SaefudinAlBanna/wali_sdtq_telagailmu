import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/daftar_spp_controller.dart';

class DaftarSppView extends GetView<DaftarSppController> {
  const DaftarSppView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DaftarSppView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DaftarSppView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
