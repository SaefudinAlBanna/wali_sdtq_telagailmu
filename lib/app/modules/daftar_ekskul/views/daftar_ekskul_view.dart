import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/daftar_ekskul_controller.dart';

class DaftarEkskulView extends GetView<DaftarEkskulController> {
  const DaftarEkskulView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DaftarEkskulView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DaftarEkskulView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
