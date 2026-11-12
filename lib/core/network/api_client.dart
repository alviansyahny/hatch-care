import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

/// Provider klien HTTP bersama untuk seluruh aplikasi.
///
/// Aturan pemakaian:
/// - Semua repository mengambil klien lewat provider ini, bukan membuat
///   `http.Client()` sendiri, supaya koneksi bisa dipakai ulang.
/// - Saat pengujian, override provider ini dengan `http.testing.MockClient`
///   agar tidak ada koneksi internet asli.
/// - Klien ditutup otomatis saat tidak lagi dipakai (`ref.onDispose`).
final apiClientProvider = Provider<Client>((ref) {
  final client = Client();
  ref.onDispose(client.close);
  return client;
});
