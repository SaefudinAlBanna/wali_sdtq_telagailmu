import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:intl/intl.dart';

import '../controllers/daftar_spp_controller.dart';

class DaftarSppView extends GetView<DaftarSppController> {
  DaftarSppView({super.key});

  final dataArgumen = Get.arguments;
  //  final data = dataArgumen['data'];

  @override
  Widget build(BuildContext context) {
    print("dataArgumen = ${dataArgumen[0]['nisn']}");
    return Scaffold(
      appBar: AppBar(title: const Text('DaftarSppView'), centerTitle: true),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: controller.getDataSPP(),
        builder: (context, snapshot) {
          // print("snapshot length = ${snapshot.data?.docs.length}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            print(snapshot.data?.docs.length);
            // print(snapshot.data?.docs.first.data());
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
                              data['tglbayar'] != null
                                  ? (data['tglbayar'] is Timestamp
                                      ? (data['tglbayar'] as Timestamp)
                                          .toDate()
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]
                                      : data['tglbayar'].toString())
                                  : '-',
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Text(
                          data['bulan'] == ""
                              ? data['bulan']
                              : data['bulan'],
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
