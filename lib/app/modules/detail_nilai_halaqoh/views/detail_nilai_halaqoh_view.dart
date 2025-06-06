import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/detail_nilai_halaqoh_controller.dart';

class DetailNilaiHalaqohView extends GetView<DetailNilaiHalaqohController> {
  const DetailNilaiHalaqohView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailNilaiHalaqohView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailNilaiHalaqohView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
