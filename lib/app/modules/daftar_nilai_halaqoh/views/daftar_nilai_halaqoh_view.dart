import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:intl/intl.dart';

import '../controllers/daftar_nilai_halaqoh_controller.dart';

class DaftarNilaiHalaqohView extends GetView<DaftarNilaiHalaqohController> {
   DaftarNilaiHalaqohView({super.key});

   final dataArgumen = Get.arguments;

  @override
  Widget build(BuildContext context) {
    print("dataArgumen = ${dataArgumen[0]['namakelas']}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('DaftarNilaiHalaqohView'),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: controller.getDataNilai(),
        builder: (context, snapshot) {
          // print("snapshot length = ${snapshot.data?.docs.length}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            print(snapshot.data?.docs.length);
            return Center(child: Text('Belum ada data nilai'));
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data();
                return GestureDetector(
                  onTap: () {
                    // Get.toNamed(
                    //   Routes.DETAIL_NILAI_HALAQOH,
                    //   arguments: data,
                    //   );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[300],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('nilai'),
                            Text(
                              data['tanggalinput']
                            )
                          ]
                        ),
                        SizedBox(height: 7),
                        Text(
                          data['manzil'] == ""
                              ? data['manzil']
                              : data['manzil'],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
