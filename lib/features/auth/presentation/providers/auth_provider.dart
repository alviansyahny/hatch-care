import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hatch_care/core/network/api_client.dart';
import 'package:hatch_care/features/auth/data/dto/auth_dto.dart';
import 'package:hatch_care/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hatch_care/features/auth/domain/models/auth_models.dart';
import 'package:hatch_care/features/auth/domain/repositories/auth_repository.dart';

/// Provider repository auth — dibuat dari klien HTTP bersama.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider));
});

/// Provider penyimpanan lokal (dioverride dengan instance nyata di main.dart).
final sessionStoreProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sessionStoreProvider harus dioverride dengan instance SharedPreferences '
    'di main.dart sebelum aplikasi dijalankan.',
  );
});

/// Provider sesi login aktif (null = belum login).
///
/// Sesi disimpan otomatis ke penyimpanan lokal sehingga pengguna tetap
/// tercatat masuk setelah aplikasi ditutup dan dibuka lagi.
final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSession?>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends Notifier<AuthSession?> {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  @override
  AuthSession? build() {
    try {
      final prefs = ref.watch(sessionStoreProvider);
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      if (token == null || userJson == null) return null;
      final user = AuthUserDto.fromJson(jsonDecode(userJson));
      if (user.id == null) return null;
      return AuthSession(
        token: token,
        user: AuthUser(
          id: user.id!,
          name: user.name ?? '',
          username: user.username ?? '',
          email: user.email ?? '',
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan sesi (user + token) ke memori dan penyimpanan lokal.
  Future<void> setSession(AuthSession session) async {
    state = session;
    try {
      final prefs = ref.read(sessionStoreProvider);
      await prefs.setString(_tokenKey, session.token);
      await prefs.setString(
        _userKey,
        jsonEncode({
          'id': session.user.id,
          'name': session.user.name,
          'username': session.user.username,
          'email': session.user.email,
        }),
      );
    } catch (_) {
      // Penyimpanan lokal tidak tersedia — sesi tetap hidup di memori.
    }
  }

  /// Menghapus sesi dari memori dan penyimpanan lokal.
  Future<void> clear() async {
    state = null;
    try {
      final prefs = ref.read(sessionStoreProvider);
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {
      // Abaikan: tidak ada lagi yang bisa dilakukan.
    }
  }
}
