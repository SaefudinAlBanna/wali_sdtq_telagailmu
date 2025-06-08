import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/tampilkan_info_sekolah_controller.dart';

class TampilkanInfoSekolahView extends GetView<TampilkanInfoSekolahController> {
  TampilkanInfoSekolahView({super.key});

  final dataArgumen = Get.arguments;

  @override
  Widget build(BuildContext context) {
    print("dataArgumen = $dataArgumen");

    var tanggalInputString = dataArgumen['tanggalinput'] as String?;
    String formattedDate = "Tanggal tidak valid";

    if (tanggalInputString != null && tanggalInputString.isNotEmpty) {
      try {
        // 1. Parse string dari Firestore ke DateTime object
        DateTime dateTime = DateTime.parse(tanggalInputString);

        // 2. Format DateTime object ke string yang diinginkan
        // 'dd' untuk hari, 'MMMM' untuk nama bulan lengkap, 'yyyy' untuk tahun
        // 'HH' untuk jam (00-23), 'mm' untuk menit
        // Locale 'en_US' digunakan untuk memastikan nama bulan dalam bahasa Inggris ("May")
        // Jika Anda ingin nama bulan dalam Bahasa Indonesia ("Mei"), gunakan 'id_ID'
        // dan pastikan Flutter di-setup untuk lokalisasi Indonesia.
        // Untuk "May" seperti permintaan, 'en_US' atau null (default locale jika English) sudah cukup.

        // formattedDate =
        //     DateFormat(
        //       'dd MMMM yyyy - HH:mm',
        //       'en_US',
        //     ).format(dateTime) +
        //     " WIB";

        formattedDate =
            "${DateFormat('dd MMMM yyyy - HH:mm', 'en_US').format(dateTime)} WIB";

        // Alternatif jika ingin "WIB" langsung di format string (kurang fleksibel untuk i18n "WIB" itu sendiri):
        // formattedDate = DateFormat("dd MMMM yyyy - HH:mm 'WIB'", 'en_US').format(dateTime);
      } catch (e) {
        print("Error parsing date '$tanggalInputString': $e");
        // Jika terjadi error parsing, tampilkan string asli atau pesan error
        formattedDate = tanggalInputString ?? "Format tanggal salah";
      }
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('TampilkanInfoSekolahView'),
      //   centerTitle: true,
      // ),
      body: ListView(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(
                  "https://fastly.picsum.photos/id/77/1631/1102.jpg?hmac=sg0ArFCRjP1wlUg8vszg5RFfGiXZJkWEtqLLCRraeBw",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(25)
                    ),
                    child: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back)))),
              ],
            ),
            // child: Image(image: NetworkImage("https://fastly.picsum.photos/id/77/1631/1102.jpg?hmac=sg0ArFCRjP1wlUg8vszg5RFfGiXZJkWEtqLLCRraeBw")),
          ),
          const SizedBox(height: 10),
          Text(
            dataArgumen['judulinformasi'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 15),
          Text("sumber : ${dataArgumen['jabatanpenginput']}"),
          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 12),
              SizedBox(width: 7),
              // Text(
              //   dataInfo['tanggalinput'],
              //   style: TextStyle(fontSize: 12),
              // ),
              Text(
                formattedDate, // <-- GUNAKAN VARIABEL YANG SUDAH DIFORMAT
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 20),
              Text(
                dataArgumen['informasisekolah'],
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
                ),
        ],
      ),
    );
  }
}
