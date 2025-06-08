import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/daftar_ekskul_controller.dart';

class DaftarEkskulView extends GetView<DaftarEkskulController> {
   DaftarEkskulView({super.key});

   final dataArgumen = Get.arguments;
   
  @override
  Widget build(BuildContext context) {
    print("dataArgumen = ${dataArgumen[0]['namakelas']}");
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
