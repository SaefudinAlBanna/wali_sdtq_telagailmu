import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/info_sekolah_controller.dart';

class InfoSekolahView extends GetView<InfoSekolahController> {
   InfoSekolahView({super.key});

   final dataArgumen = Get.arguments;

  @override
  Widget build(BuildContext context) {
    print("dataArgumen = ${dataArgumen[0]['namakelas']}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Komite'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ada Info apa hari ini?', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: controller.judulC,
              decoration: InputDecoration(
                hintText: 'Judul info',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.inputC,
              decoration: InputDecoration(
                hintText: 'Tulis Info...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 15, // Untuk membuat input multiline seperti status Facebook
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ignore: unnecessary_null_comparison
                if(controller.judulC.text == null || controller.judulC.text == '' || controller.judulC.text.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Judul masih kosong',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    );
                }
                // ignore: unnecessary_null_comparison
                else if(controller.inputC.text == null || controller.inputC.text == '' || controller.inputC.text.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Info masih kosong',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    );
                  // controller.simpanInfo();
                  //  String input = controller.inputC.text;
                  // print('Input Status: $input');
                } else {
                  // Get.snackbar(
                  //   'Error',
                  //   'Info masih kosong',
                  //   backgroundColor: Colors.red,
                  //   colorText: Colors.white,
                  //   );
                  controller.simpanInfo();
                  // controller.test();
                  //  String input = controller.inputC.text;
                  // print('Input Status: $input');
                }
               
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
