import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final myItem = [
    ImageSlider(
      image: "assets/pictures/1.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/2.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/3.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/4.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/5.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/6.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/7.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/8.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/9.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/10.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/11.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/12.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/13.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/14.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
    ImageSlider(
      image: "assets/pictures/15.jpg",
      ontap: () => Get.snackbar("Informasi", ""),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: controller.userStreamBaru(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null || snapshot.data!.data() == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Data tidak ditemukan'),
                Text('Silahkan Logout terlebih dahulu, kemudian Login ulang'),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    controller.signOut();
                    Get.snackbar('Login', 'Silahkan login ulang');
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data!.data()!;
          return Scaffold(
            body: ListView(
              children: [
                Stack(
                  fit: StackFit.passthrough,
                  children: [
                    ClipPath(
                      clipper: ClassClipPathTop(),
                      child: Container(
                        height: 300,
                        // width: Get.width,
                        decoration: BoxDecoration(
                          color: Colors.indigo[400],
                          image: DecorationImage(
                            image: AssetImage("assets/pictures/sekolah.jpg"),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 120),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                margin: EdgeInsets.symmetric(horizontal: 25),
                                height: 145,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      // spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(
                                          alpha: 0.5,
                                        ),
                                        // spreadRadius: 10,
                                        blurRadius: 5,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                    color: Colors.indigo[900],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 10),
                                              Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      "https://ui-avatars.com/api/?name=${data['nama']}",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                data['nama']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                future: controller.getDataKelas(),
                                                // future: null,
                                                builder: (
                                                  context,
                                                  snapshotDataKelas,
                                                ) {
                                                  if (snapshotDataKelas
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                  if (snapshotDataKelas.data == null) {
                                                    return Center(
                                                      child: Text(
                                                        "kelas Belum di input",
                                                      ),
                                                    );
                                                  }
                                                  if (snapshotDataKelas
                                                      .hasData) {
                                                    var kelasDocs = snapshotDataKelas.data!;
                                                    String namaKelas = kelasDocs.docs.isNotEmpty
                                                        ? (kelasDocs.docs.first.data()['namakelas'] ?? 'N/A').toString()
                                                        : 'N/A';
                                                    return Text(
                                                      namaKelas,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  } else {
                                                    return Center(
                                                      child: Text(
                                                        "Terjadi kesalahan, periksa koneksi internet",
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // SizedBox(height: 10),
                                      // Divider(height: 2, color: Colors.black),
                                    ],
                                  ),
                                ),
                              ),

                              // SizedBox(height: 1),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                margin: EdgeInsets.symmetric(horizontal: 25),
                                height: 120,
                                width: Get.width,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      // spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [

                                       // AGIS
                                      MenuAtas(
                                        title: 'AGIS',
                                        // icon: Icon(Icons.view_timeline_outlined),
                                        gambar: "assets/png/snack.png",
                                        onTap: () async {
                                          final dataSiswaFuture =
                                              controller.getDataKelas();
                                          dataSiswaFuture.then((snapshot) {
                                            final dataSiswa = snapshot.docs;
                                            // print('Data yang dikirim: $dataSiswa');
                                            Get.toNamed(
                                              Routes.JADWAL_AGIS,
                                              arguments: dataSiswa,
                                           );
                                          });
                                        },
                                      ),
                                  
                                      // JADWAL PELAJARAN
                                      MenuAtas(
                                        title: 'Jadwal Pelajaran',
                                        // icon: Icon(Icons.view_timeline_outlined),
                                        gambar: "assets/png/daftar_list.png",
                                        onTap: () async {
                                           final dataSiswaFuture =
                                              controller.getDataKelas();
                                          dataSiswaFuture.then((snapshot) {
                                            final dataSiswa = snapshot.docs;
                                            // print('Data yang dikirim: $dataSiswa');
                                            Get.toNamed(
                                              Routes.JADWAL_PELAJARAN,
                                              arguments: dataSiswa,
                                            );
                                          });
                                        },
                                      ),

                                      
                                      // MATA PELAJARAN
                                      MenuAtas(
                                        title: 'Mata Pelajaran',
                                        // icon: Icon(Icons.menu_book_sharp),
                                        gambar: "assets/png/papan_list.png",
                                        onTap: () async {
                                           final dataSiswaFuture =
                                              controller.getDataKelas();
                                          dataSiswaFuture.then((snapshot) {
                                            final dataSiswa = snapshot.docs;
                                            // print('Data yang dikirim: $dataSiswa');
                                            Get.toNamed(
                                              Routes.DAFTAR_MATA_PELAJARAN,
                                              arguments: dataSiswa,
                                            );
                                          });
                                        },
                                      ),
                                  
                                      // HALAQOH 
                                      MenuAtas(
                                        title: 'Halaqoh',
                                        // icon: Icon(Icons.sports_gymnastics_rounded),
                                        gambar: "assets/png/jurnal_ajar.png",
                                        onTap: () async {
                                         final dataSiswaFuture =
                                              controller.getDataKelas();
                                          dataSiswaFuture.then((snapshot) {
                                            final dataSiswa = snapshot.docs;
                                            // print('Data yang dikirim: $dataSiswa');
                                            Get.toNamed(
                                              Routes.DAFTAR_NILAI_HALAQOH,
                                              arguments: dataSiswa,
                                           );
                                          });
                                        },
                                      ),
                                     
                                      //EKSKUL
                                      MenuAtas(
                                        title: 'Ekskul',
                                        // icon: Icon(Icons.sports_gymnastics_rounded),
                                        gambar: "assets/png/toga_lcd.png",
                                        onTap: () async {
                                         final dataSiswaFuture =
                                              controller.getDataKelas();
                                          dataSiswaFuture.then((snapshot) {
                                            final dataSiswa = snapshot.docs;
                                            // print('Data yang dikirim: $dataSiswa');
                                            Get.toNamed(
                                              Routes.DAFTAR_EKSKUL,
                                              arguments: dataSiswa,
                                           );
                                          });
                                        },
                                      ),
                                      
                                       //  SPP
                                      MenuAtas(
                                        title: 'Spp',
                                        // icon: Icon(Icons.info_outline_rounded),
                                        gambar: "assets/png/buku_uang.png",
                                        onTap: () async {
                                          final dataSiswaFuture =
                                              controller.getDataKelas();
                                          dataSiswaFuture.then((snapshot) {
                                            final dataSiswa = snapshot.docs;
                                            // print('Data yang dikirim: $dataSiswa');
                                            Get.toNamed(
                                              Routes.DAFTAR_SPP,
                                              arguments: dataSiswa,
                                           );
                                          });
                                        },
                                      ),
                                      
                                      //  KOMITE
                                      MenuAtas(
                                        title: 'Komite',
                                        // icon: Icon(Icons.info_outline_rounded),
                                        gambar: "assets/png/uang.png",
                                        onTap: () async {
                                         final dataSiswaFuture =
                                              controller.getDataKelas();
                                          dataSiswaFuture.then((snapshot) {
                                            final dataSiswa = snapshot.docs;
                                            // print('Data yang dikirim: $dataSiswa');
                                            Get.toNamed(
                                              Routes.DAFTAR_PEMBAYARAN_KOMITE,
                                              arguments: dataSiswa,
                                           );
                                          });
                                        },
                                      ),
                                    
                                       // INFO KOMITE
                                      MenuAtas(
                                        title: 'Info Komite',
                                        // icon: Icon(Icons.info_outline_rounded),
                                        gambar: "assets/png/pengumuman.png",
                                        onTap: () {
                                          Get.toNamed(Routes.INFO_SEKOLAH);
                                        },
                                      ),
                                    
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),


                              // --- AWAL BAGIAN JURNAL CAROUSEL AI ---
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     left: 20,
                              //     top: 20,
                              //     bottom: 10,
                              //     right: 20,
                              //   ),

                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text(
                              //         "Jurnal Kelas Hari Ini",
                              //         style: TextStyle(
                              //           fontSize: 18,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //       Obx(
                              //         () => Text(
                              //           controller.jamPelajaranRx.value,
                              //           style: TextStyle(
                              //             fontSize: 12,
                              //             color: Colors.grey[700],
                              //           ),
                              //         ),
                              //       ),

                              //       Obx(() {
                              //         // Obx untuk merebuild saat isLoadingInitialData atau kelasAktifList berubah
                              //         if (controller
                              //             .isLoadingInitialData
                              //             .value) {
                              //           return SizedBox(
                              //             height: 150,
                              //             child: Center(
                              //               child: CircularProgressIndicator(
                              //                 key: ValueKey(
                              //                   "jurnalLoaderInitial",
                              //                 ),
                              //               ),
                              //             ),
                              //           );
                              //         }
                              //         if (controller.idTahunAjaran == null) {
                              //           return SizedBox(
                              //             height: 150,
                              //             child: Center(
                              //               child: Text(
                              //                 "Tahun ajaran tidak termuat.",
                              //               ),
                              //             ),
                              //           );
                              //         }
                              //         if (controller.kelasAktifList.isEmpty) {
                              //           return SizedBox(
                              //             height: 150,
                              //             child: Center(
                              //               child: Column(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment.center,
                              //                 children: [
                              //                   // Lottie.asset('assets/lotties/empty.json', height: 80), // Ganti dengan Lottie yang sesuai
                              //                   Icon(
                              //                     Icons.class_outlined,
                              //                     size: 50,
                              //                     color: Colors.grey[400],
                              //                   ),
                              //                   SizedBox(height: 8),
                              //                   Text(
                              //                     "Tidak ada kelas aktif ditemukan.",
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           );
                              //         }

                              //         // Carousel hanya dibangun jika ada kelas
                              //         return CarouselSlider(
                              //           options: CarouselOptions(
                              //             height: 170, // Sesuaikan tinggi
                              //             viewportFraction: 0.9,
                              //             autoPlay:
                              //                 true, // Matikan autoplay agar user bisa fokus
                              //             enlargeCenterPage: true,
                              //             enableInfiniteScroll:
                              //                 controller.kelasAktifList.length >
                              //                 1,
                              //           ),
                              //           items:
                              //               controller.kelasAktifList.map((
                              //                 docKelas,
                              //               ) {
                              //                 final String idKelas =
                              //                     docKelas.id;
                              //                 final String namaKelas =
                              //                     docKelas
                              //                         .data()?['namakelas'] ??
                              //                     'Nama Kelas Tdk Ada';
                              //                 return Builder(
                              //                   // Builder diperlukan agar context benar untuk Obx dalam map
                              //                   builder: (
                              //                     BuildContext context,
                              //                   ) {
                              //                     return Container(
                              //                       width:
                              //                           MediaQuery.of(
                              //                             context,
                              //                           ).size.width,
                              //                       margin:
                              //                           EdgeInsets.symmetric(
                              //                             horizontal: 5.0,
                              //                             vertical: 10.0,
                              //                           ),
                              //                       padding: EdgeInsets.all(12),
                              //                       decoration: BoxDecoration(
                              //                         color:
                              //                             Colors
                              //                                 .white, // Ganti warna dasar kartu
                              //                         borderRadius:
                              //                             BorderRadius.circular(
                              //                               12,
                              //                             ),
                              //                         boxShadow: [
                              //                           BoxShadow(
                              //                             color: Colors.grey
                              //                                 .withOpacity(0.2),
                              //                             spreadRadius: 1,
                              //                             blurRadius: 4,
                              //                             offset: Offset(0, 2),
                              //                           ),
                              //                         ],
                              //                       ),
                              //                       child: Column(
                              //                         crossAxisAlignment:
                              //                             CrossAxisAlignment
                              //                                 .start,
                              //                         children: [
                              //                           Text(
                              //                             namaKelas,
                              //                             style: TextStyle(
                              //                               fontSize: 18,
                              //                               fontWeight:
                              //                                   FontWeight.bold,
                              //                               color:
                              //                                   Theme.of(
                              //                                     context,
                              //                                   ).primaryColor,
                              //                             ),
                              //                           ),
                              //                           Divider(height: 15),
                              //                           Expanded(
                              //                             // Agar konten jurnal mengisi sisa ruang
                              //                             child: Obx(() {
                              //                               // Obx untuk jamPelajaranRx
                              //                               String
                              //                               currentJamDocId =
                              //                                   controller
                              //                                       .jamPelajaranRx
                              //                                       .value;

                              //                               if (currentJamDocId ==
                              //                                       'Memuat jam...' ||
                              //                                   currentJamDocId
                              //                                       .isEmpty) {
                              //                                 return Center(
                              //                                   child: Text(
                              //                                     currentJamDocId,
                              //                                     style: TextStyle(
                              //                                       color:
                              //                                           Colors
                              //                                               .grey,
                              //                                     ),
                              //                                   ),
                              //                                 );
                              //                               }
                              //                               if (currentJamDocId ==
                              //                                   'Tidak ada jam pelajaran') {
                              //                                 return Center(
                              //                                   child: Column(
                              //                                     mainAxisAlignment:
                              //                                         MainAxisAlignment
                              //                                             .center,
                              //                                     children: [
                              //                                       Icon(
                              //                                         Icons
                              //                                             .access_time_filled,
                              //                                         size: 30,
                              //                                         color:
                              //                                             Colors
                              //                                                 .orangeAccent,
                              //                                       ),
                              //                                       SizedBox(
                              //                                         height: 5,
                              //                                       ),
                              //                                       Text(
                              //                                         "Tidak ada jadwal saat ini",
                              //                                         textAlign:
                              //                                             TextAlign
                              //                                                 .center,
                              //                                       ),
                              //                                     ],
                              //                                   ),
                              //                                 );
                              //                               }
                              //                               return StreamBuilder<
                              //                                 DocumentSnapshot<
                              //                                   Map<
                              //                                     String,
                              //                                     dynamic
                              //                                   >
                              //                                 >
                              //                               >(
                              //                                 key: ValueKey(
                              //                                   "$idKelas-$currentJamDocId-${controller.idTahunAjaran}",
                              //                                 ),
                              //                                 stream: controller
                              //                                     .getStreamJurnalDetail(
                              //                                       idKelas,
                              //                                       currentJamDocId,
                              //                                     ),
                              //                                 builder: (
                              //                                   context,
                              //                                   snapJurnalDetail,
                              //                                 ) {
                              //                                   if (snapJurnalDetail
                              //                                           .connectionState ==
                              //                                       ConnectionState
                              //                                           .waiting) {
                              //                                     return Center(
                              //                                       child: SizedBox(
                              //                                         width: 20,
                              //                                         height:
                              //                                             20,
                              //                                         child: CircularProgressIndicator(
                              //                                           strokeWidth:
                              //                                               2,
                              //                                           key: ValueKey(
                              //                                             "jurnalDetailLoader-$idKelas",
                              //                                           ),
                              //                                         ),
                              //                                       ),
                              //                                     );
                              //                                   }
                              //                                   if (snapJurnalDetail
                              //                                       .hasError) {
                              //                                     return Center(
                              //                                       child: Text(
                              //                                         "Error: ${snapJurnalDetail.error}",
                              //                                         style: TextStyle(
                              //                                           color:
                              //                                               Colors.red,
                              //                                         ),
                              //                                       ),
                              //                                     );
                              //                                   }
                              //                                   if (!snapJurnalDetail
                              //                                           .hasData ||
                              //                                       !snapJurnalDetail
                              //                                           .data!
                              //                                           .exists ||
                              //                                       snapJurnalDetail
                              //                                               .data!
                              //                                               .data() ==
                              //                                           null) {
                              //                                     return Center(
                              //                                       child: Column(
                              //                                         mainAxisAlignment:
                              //                                             MainAxisAlignment
                              //                                                 .center,
                              //                                         children: [
                              //                                           Icon(
                              //                                             Icons
                              //                                                 .description_outlined,
                              //                                             size:
                              //                                                 30,
                              //                                             color:
                              //                                                 Colors.blueGrey[300],
                              //                                           ),
                              //                                           SizedBox(
                              //                                             height:
                              //                                                 5,
                              //                                           ),
                              //                                           Text(
                              //                                             "Jurnal belum diisi untuk jam ini",
                              //                                             textAlign:
                              //                                                 TextAlign.center,
                              //                                             style: TextStyle(
                              //                                               color:
                              //                                                   Colors.blueGrey[700],
                              //                                             ),
                              //                                           ),
                              //                                         ],
                              //                                       ),
                              //                                     );
                              //                                   }

                              //                                   var dataJurnalMap =
                              //                                       snapJurnalDetail
                              //                                           .data!
                              //                                           .data()!;
                              //                                   return Container(
                              //                                     padding:
                              //                                         EdgeInsets.all(
                              //                                           8,
                              //                                         ),
                              //                                     decoration: BoxDecoration(
                              //                                       color:
                              //                                           Colors
                              //                                               .teal[50], // Warna latar detail jurnal
                              //                                       borderRadius:
                              //                                           BorderRadius.circular(
                              //                                             8,
                              //                                           ),
                              //                                     ),
                              //                                     child: Column(
                              //                                       crossAxisAlignment:
                              //                                           CrossAxisAlignment
                              //                                               .start,
                              //                                       mainAxisAlignment:
                              //                                           MainAxisAlignment
                              //                                               .center, // Pusatkan konten
                              //                                       children: [
                              //                                         Text(
                              //                                           "Jam: ${dataJurnalMap['jampelajaran'] ?? 'N/A'}",
                              //                                           style: TextStyle(
                              //                                             fontSize:
                              //                                                 13,
                              //                                             fontWeight:
                              //                                                 FontWeight.w500,
                              //                                           ),
                              //                                         ),
                              //                                         SizedBox(
                              //                                           height:
                              //                                               4,
                              //                                         ),
                              //                                         Text(
                              //                                           "Materi: ${dataJurnalMap['materipelajaran'] ?? 'Belum ada materi'}",
                              //                                           style: TextStyle(
                              //                                             fontSize:
                              //                                                 14,
                              //                                           ),
                              //                                           maxLines:
                              //                                               3,
                              //                                           overflow:
                              //                                               TextOverflow.ellipsis,
                              //                                         ),
                              //                                         // Tambahkan field lain jika ada, misal:
                              //                                         // if (dataJurnalMap['keterangan'] != null && dataJurnalMap['keterangan'].isNotEmpty)
                              //                                         //   Padding(
                              //                                         //     padding: const EdgeInsets.only(top: 4.0),
                              //                                         //     child: Text("Ket: ${dataJurnalMap['keterangan']}", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis,),
                              //                                         //   ),
                              //                                       ],
                              //                                     ),
                              //                                   );
                              //                                 },
                              //                               );
                              //                             }),
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     );
                              //                   },
                              //                 );
                              //               }).toList(),
                              //         );
                              //       }),
                              //     ],
                              //   ),
                              // ),


                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                // JUDUL INFORMASI SEKOLAH (BAWAH)
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Informasi Sekolah",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Get.snackbar(
                              "Info",
                              "Nanti akan muncul page berita lengkap",
                            );
                          },
                          child: Text("Selengkapnya"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),

                  // INFORMASI SEKOLAH (BAWAH)
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: controller.getDataInfo(),
                    builder: (context, snapInfo) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.data == null ||
                          (snapshot.data != null &&
                              (snapshot.data!.data() == null ||
                                  (snapshot.data!.data() as Map).isEmpty))) {
                        return Center(child: Text('Belum ada informasi'));
                      } else if (snapInfo.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapInfo.data!.docs.length,
                          itemBuilder: (context, index) {
                            var dataInfo = snapInfo.data!.docs[index].data();
                            var tanggalInputString =
                                dataInfo['tanggalinput'] as String?;
                            String formattedDate = "Tanggal tidak valid";

                            if (tanggalInputString != null &&
                                tanggalInputString.isNotEmpty) {
                              try {
                                // 1. Parse string dari Firestore ke DateTime object
                                DateTime dateTime = DateTime.parse(
                                  tanggalInputString,
                                );

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
                                print(
                                  "Error parsing date '$tanggalInputString': $e",
                                );
                                // Jika terjadi error parsing, tampilkan string asli atau pesan error
                                formattedDate = tanggalInputString ?? "Format tanggal salah";
                              }
                            }

                            return InkWell(
                              onTap: () {
                                Get.toNamed(
                                  Routes.TAMPILKAN_INFO_SEKOLAH,
                                  arguments: dataInfo,
                                );
                              },
                              child: Container(
                                // margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                                margin: EdgeInsets.fromLTRB(
                                  15,
                                  (index == 0 ? 15 : 0),
                                  15,
                                  15,
                                ),
                                // Beri margin atas untuk item pertama
                                padding: EdgeInsets.all(10),

                                // height: 50,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      // spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                  color: Colors.grey.shade50,
                                  // color: Colors.brown,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      height: 75,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.grey,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            "https://picsum.photos/id/${index + 356}/500/500",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            dataInfo['judulinformasi'],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            // "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla eget placerat ipsum. Quisque sed metus elit. Phasellus viverra, magna tristique auctor volutpat, neque orci bibendum magna, vel varius augue felis quis ex.",
                                            dataInfo['informasisekolah'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_outlined,
                                                size: 12,
                                              ),
                                              SizedBox(width: 7),
                                              // Text(
                                              //   dataInfo['tanggalinput'],
                                              //   style: TextStyle(fontSize: 12),
                                              // ),
                                              Text(
                                                formattedDate, // <-- GUNAKAN VARIABEL YANG SUDAH DIFORMAT
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // return Center(child: CircularProgressIndicator());
                        return Center(child: Text("Ada Kesalahan."));
                      }
                    },
                  ),
              ],
            ),
          );
        } else {
          return Center(child: Text('Terjadi kesalahan, cek koneksi internet'));
        }
      },
    );
  }
}

class ImageSlider extends StatelessWidget {
  const ImageSlider({super.key, required this.image, required this.ontap});

  final String image;
  final Function() ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class MenuAtas extends StatelessWidget {
  const MenuAtas({
    super.key,
    required this.title,
    required this.gambar,
    // required this.icon,
    required this.onTap,
  });

  final String title;
  // final Icon icon;
  final String gambar;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(7),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                // child: Icon(icon.icon, size: 40, color: Colors.white),
                child: Image.asset(gambar, fit: BoxFit.contain),
              ),
            ),
          ),
          SizedBox(height: 3),
          SizedBox(
            width: 55,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class ClassClipPathTop extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => false;
}
