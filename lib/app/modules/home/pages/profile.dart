import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class ProfilePage extends GetView<HomeController> {
  final AuthController authC =
      Get.find(); // Dapatkan AuthController jika diperlukan di view
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: controller.userStreamBaru(),
      builder: (context, snapshotprofil) {
        if (snapshotprofil.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshotprofil.data!.data() == null ||
            snapshotprofil.data == null) {
          return Center(
            child: Column(
              children: [
                Text('Data tidak ditemukan'),
                Text('Silahkan Logout terlebih dahulu, kemudian Login ulang'),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(Routes.HOME);
                    Get.snackbar('Login', 'Silahkan login ulang');
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          );
          // return
        } else if (snapshotprofil.hasData) {
          Map<String, dynamic> datasiswa = snapshotprofil.data!.data()!;

          // LANGSUNG CEK FIELD DARI FIRESTORE
          final String? imageUrlFromDb = datasiswa['profileImageUrl'];

          final ImageProvider imageProvider;
          // Cek apakah URL dari DB valid (tidak null dan tidak kosong)
          if (imageUrlFromDb != null && imageUrlFromDb.isNotEmpty) {
            imageProvider = NetworkImage(imageUrlFromDb);
          } else {
            // Jika tidak, gunakan aset lokal
            imageProvider = const AssetImage('assets/png/logo.png');
          }

          String tglLahir = datasiswa['tanggalLahir'];
          DateTime? tglLahirDate;
          try {
            tglLahirDate = DateFormat('EEEE, dd MMMM, yyyy').parse(tglLahir);
          } catch (e) {
            tglLahirDate = null;
          }
          String formattedDateTglLahir =
              tglLahirDate != null
                  ? DateFormat('dd MMMM, yyyy').format(tglLahirDate)
                  : tglLahir;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Profile",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.indigo[400],
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Logout",
                      middleText: "Anda yakin ingin keluar dari akun ini?",
                      textConfirm: "Logout",
                      textCancel: "Batal",
                      onConfirm: () async {
                        await Get.find<AuthController>().signOut();
                        // Navigasi akan dihandle oleh StreamBuilder di main.dart atau listener di AuthController
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.switch_account),
                  onPressed: () async {
                    // Logout dulu user Firebase saat ini agar AccountSwitcherView bisa menampilkan semua akun
                    // termasuk akun yang baru saja logout, tanpa langsung login kembali ke akun yang sama.
                    await Get.find<AuthController>().signOut();
                    // Navigasi ke AccountSwitcherView akan dihandle otomatis oleh listener di AuthController
                    // atau StreamBuilder di main.dart.
                    // Jika ingin eksplisit:
                    // Get.offAllNamed(Routes.ACCOUNT_SWITCHER);
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                ClipPath(
                  clipper: ClassClipPathTop(),
                  child: Container(
                    height: 250,
                    width: Get.width,
                    color: Colors.indigo[400],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Column(
                            children: [
                              // --- BAGIAN YANG DIUBAH ---
                              Stack(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      // Gunakan URL dari Firestore
                                      image: DecorationImage(
                                        // image: NetworkImage(profileImageUrl),
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        // Tambahkan onError untuk menangani jika URL NetworkImage gagal dimuat
                                        onError: (exception, stackTrace) {
                                          print(
                                            'Error loading profile image: $exception',
                                          );
                                          // Di sini Anda bisa mengubah state untuk menampilkan placeholder jika mau,
                                          // tapi CircleAvatar akan menampilkan backgroundColor jika gagal.
                                        },
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.indigo[400],
                                        ),
                                        // Panggil fungsi upload dari controller
                                        onPressed: () {
                                          controller
                                              .pickAndUploadProfilePicture();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // --- AKHIR BAGIAN YANG DIUBAH ---
                              SizedBox(height: 20),
                              Text(
                                datasiswa['nama'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                datasiswa['email'].toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                          // Container(height: 7, color: Colors.grey[400]),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          children: [
                            SizedBox(height: 20),
                            Text("Menu", style: TextStyle(fontSize: 20)),
                            SizedBox(height: 5),
                            Card(
                              color: Colors.grey[200],
                              child: Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    ...ListTile.divideTiles(
                                      color: Colors.grey,
                                      tiles: [
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(Icons.email_outlined),
                                          title: Text("email"),
                                          subtitle: Text(datasiswa['email']),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(Icons.local_hospital),
                                          title: Text("Tempat, Tgl Lahir"),
                                          subtitle: Text(
                                            "${datasiswa['tempatLahir']}, - $formattedDateTglLahir",
                                          ),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(Icons.male_outlined),
                                          title: Text("Jenis Kelamin"),
                                          subtitle: Text(
                                            datasiswa['jeniskelamin'],
                                          ),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(Icons.ac_unit_outlined),
                                          title: Text("Jumlah Hafalan"),
                                          subtitle: Text(datasiswa['email']),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(Icons.my_location),
                                          title: Text("Alamat"),
                                          subtitle: Text(datasiswa['alamat']),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(
                                            Icons.phone_android_outlined,
                                          ),
                                          title: Text("No Hp"),
                                          subtitle: Text(datasiswa['email']),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(
                                            Icons.menu_book_outlined,
                                          ),
                                          title: Text("bersertifikat"),
                                          subtitle: Text(datasiswa['email']),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          leading: Icon(Icons.yard_outlined),
                                          title: Text("No. Sertifikat"),
                                          subtitle: Text(datasiswa['email']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text("Terjadi kesalahan, silahkan coba login ulang"),
          );
        }
      },
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
