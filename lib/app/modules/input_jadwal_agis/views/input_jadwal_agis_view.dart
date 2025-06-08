import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/input_jadwal_agis_controller.dart';

class InputJadwalAgisView extends GetView<InputJadwalAgisController> {
  const InputJadwalAgisView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InputJadwalAgisView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'InputJadwalAgisView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
