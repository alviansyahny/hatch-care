import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;

/// Kesalahan jaringan yang sudah dipetakan ke pesan berbahasa Indonesia.
///
/// Semua lapisan repository melempar tipe ini — layar tidak boleh
/// menampilkan teks exception mentah.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Pesan siap tampilkan ke pengguna (Bahasa Indonesia).
  final String message;

  /// Kode status HTTP jika ada (null saat gagal jaringan/timeout).
  final int? statusCode;

  @override
  String toString() => message;

  static const ApiException tidakAdaKoneksi = ApiException(
    'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
  );

  static const ApiException habisWaktu = ApiException(
    'Koneksi ke server habis waktu. Coba lagi.',
  );

  static ApiException serverError(int? statusCode) => ApiException(
    statusCode == null
        ? 'Server bermasalah. Coba lagi nanti.'
        : 'Server bermasalah (kode $statusCode). Coba lagi nanti.',
    statusCode: statusCode,
  );

  static const ApiException dataTidakValid = ApiException(
    'Data dari server tidak dapat dipahami.',
  );

  /// Mengubah exception mentah (socket, timeout, klien HTTP) menjadi
  /// [ApiException] dengan pesan Indonesia.
  static ApiException from(Object error, {int? statusCode}) {
    if (error is ApiException) return error;
    if (error is TimeoutException) return habisWaktu;
    if (error is SocketException ||
        error is HttpException ||
        error is ClientException) {
      return tidakAdaKoneksi;
    }
    return tidakAdaKoneksi;
  }
}
