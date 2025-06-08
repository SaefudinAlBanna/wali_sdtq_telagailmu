import 'package:get/get.dart';

import '../modules/account_switcher/bindings/account_switcher_binding.dart';
import '../modules/account_switcher/views/account_switcher_view.dart';
import '../modules/daftar_ekskul/bindings/daftar_ekskul_binding.dart';
import '../modules/daftar_ekskul/views/daftar_ekskul_view.dart';
import '../modules/daftar_mata_pelajaran/bindings/daftar_mata_pelajaran_binding.dart';
import '../modules/daftar_mata_pelajaran/views/daftar_mata_pelajaran_view.dart';
import '../modules/daftar_nilai_halaqoh/bindings/daftar_nilai_halaqoh_binding.dart';
import '../modules/daftar_nilai_halaqoh/views/daftar_nilai_halaqoh_view.dart';
import '../modules/daftar_pembayaran_komite/bindings/daftar_pembayaran_komite_binding.dart';
import '../modules/daftar_pembayaran_komite/views/daftar_pembayaran_komite_view.dart';
import '../modules/daftar_spp/bindings/daftar_spp_binding.dart';
import '../modules/daftar_spp/views/daftar_spp_view.dart';
import '../modules/detail_nilai_halaqoh/bindings/detail_nilai_halaqoh_binding.dart';
import '../modules/detail_nilai_halaqoh/views/detail_nilai_halaqoh_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/info_sekolah/bindings/info_sekolah_binding.dart';
import '../modules/info_sekolah/views/info_sekolah_view.dart';
import '../modules/input_dana_komite/bindings/input_dana_komite_binding.dart';
import '../modules/input_dana_komite/views/input_dana_komite_view.dart';
import '../modules/input_jadwal_agis/bindings/input_jadwal_agis_binding.dart';
import '../modules/input_jadwal_agis/views/input_jadwal_agis_view.dart';
import '../modules/jadwal_agis/bindings/jadwal_agis_binding.dart';
import '../modules/jadwal_agis/views/jadwal_agis_view.dart';
import '../modules/jadwal_pelajaran/bindings/jadwal_pelajaran_binding.dart';
import '../modules/jadwal_pelajaran/views/jadwal_pelajaran_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/new_password/bindings/new_password_binding.dart';
import '../modules/new_password/views/new_password_view.dart';
import '../modules/tampilkan_info_sekolah/bindings/tampilkan_info_sekolah_binding.dart';
import '../modules/tampilkan_info_sekolah/views/tampilkan_info_sekolah_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.NEW_PASSWORD,
      page: () => const NewPasswordView(),
      binding: NewPasswordBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL_PELAJARAN,
      page: () => JadwalPelajaranView(),
      binding: JadwalPelajaranBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_MATA_PELAJARAN,
      page: () => DaftarMataPelajaranView(),
      binding: DaftarMataPelajaranBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_EKSKUL,
      page: () => DaftarEkskulView(),
      binding: DaftarEkskulBinding(),
    ),
    GetPage(
      name: _Paths.INFO_SEKOLAH,
      page: () => InfoSekolahView(),
      binding: InfoSekolahBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_NILAI_HALAQOH,
      page: () => DaftarNilaiHalaqohView(),
      binding: DaftarNilaiHalaqohBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_NILAI_HALAQOH,
      page: () => const DetailNilaiHalaqohView(),
      binding: DetailNilaiHalaqohBinding(),
    ),
    GetPage(
      name: _Paths.TAMPILKAN_INFO_SEKOLAH,
      page: () => TampilkanInfoSekolahView(),
      binding: TampilkanInfoSekolahBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_SWITCHER,
      page: () => const AccountSwitcherView(),
      binding: AccountSwitcherBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_SPP,
      page: () => DaftarSppView(),
      binding: DaftarSppBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_PEMBAYARAN_KOMITE,
      page: () => DaftarPembayaranKomiteView(),
      binding: DaftarPembayaranKomiteBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL_AGIS,
      page: () => JadwalAgisView(),
      binding: JadwalAgisBinding(),
    ),
    GetPage(
      name: _Paths.INPUT_JADWAL_AGIS,
      page: () => const InputJadwalAgisView(),
      binding: InputJadwalAgisBinding(),
    ),
    GetPage(
      name: _Paths.INPUT_DANA_KOMITE,
      page: () => const InputDanaKomiteView(),
      binding: InputDanaKomiteBinding(),
    ),
  ];
}
