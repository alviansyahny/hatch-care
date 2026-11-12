import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;

import 'package:hatch_care/core/config/app_config.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/auth/data/dto/auth_dto.dart';
import 'package:hatch_care/features/auth/domain/models/auth_models.dart';
import 'package:hatch_care/features/auth/domain/repositories/auth_repository.dart';

/// Implementasi [AuthRepository] memakai klien HTTP bersama.
///
/// Alamat server dibaca dari [AppConfig.authApiBaseUrl].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final Client _client;

  String get _base => AppConfig.authApiBaseUrl;

  @override
  Future<AuthSession> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_base/api/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: 15));
      if (res.statusCode == 201) {
        return _toSession(AuthSessionDto.fromJson(jsonDecode(res.body)));
      }
      throw _errorFromResponse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<AuthSession> login({
    required String login,
    required String password,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_base/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'login': login, 'password': password}),
          )
          .timeout(Duration(seconds: 15));
      if (res.statusCode == 200) {
        return _toSession(AuthSessionDto.fromJson(jsonDecode(res.body)));
      }
      throw _errorFromResponse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<AuthUser> me({required String token}) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$_base/api/user'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(Duration(seconds: 10));
      if (res.statusCode == 200) {
        final dto = AuthMeDto.fromJson(jsonDecode(res.body));
        final user = dto.user;
        if (user?.id == null) throw ApiException.dataTidakValid;
        return _toUser(user!);
      }
      throw _errorFromResponse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<void> logout({required String token}) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_base/api/logout'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw _errorFromResponse(res);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  // --- Mapper & error -------------------------------------------------------

  AuthSession _toSession(AuthSessionDto dto) {
    if (dto.token == null || dto.user?.id == null) {
      throw ApiException.dataTidakValid;
    }
    return AuthSession(token: dto.token!, user: _toUser(dto.user!));
  }

  AuthUser _toUser(AuthUserDto dto) => AuthUser(
    id: dto.id ?? 0,
    name: dto.name ?? '',
    username: dto.username ?? '',
    email: dto.email ?? '',
  );

  /// Mengubah response gagal (422/401/500) menjadi [ApiException] berbahasa
  /// Indonesia dengan isi pesan validasi dari Laravel bila ada.
  ApiException _errorFromResponse(dynamic res) {
    final statusCode = res.statusCode as int?;
    final body = res.body as String;

    // 422: data tidak lulus validasi Laravel.
    if (statusCode == 422) {
      final message = _validationMessage(body);
      if (message != null) return ApiException(message, statusCode: 422);
      return const ApiException('Data yang dikirim tidak valid.', statusCode: 422);
    }

    // 401: token tidak valid / kredensial salah.
    if (statusCode == 401) {
      return const ApiException('Sesi berakhir. Silakan masuk kembali.', statusCode: 401);
    }

    return ApiException.serverError(statusCode);
  }

  /// Mengambil pesan validasi pertama dari response Laravel dan
  /// menerjemahkan frasa umum ke Bahasa Indonesia.
  String? _validationMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return null;
      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty && first.first is String) {
          return _translate(first.first as String);
        }
      }
      final message = decoded['message'];
      if (message is String && message.isNotEmpty) return _translate(message);
      return null;
    } catch (_) {
      return null;
    }
  }

  String _translate(String message) {
    var result = message;
    const replacements = [
      (' has already been taken.', ' sudah digunakan.'),
      (' is required', ' wajib diisi'),
      (' must be', ' harus'),
      ('The login field', 'Username atau email'),
      ('The username field', 'Username'),
      ('The email field', 'Email'),
      ('The name field', 'Nama'),
      ('The password field', 'Kata sandi'),
      ('The username', 'Username'),
      ('The email', 'Email'),
      ('The name', 'Nama'),
      ('The password', 'Kata sandi'),
    ];
    for (final (en, idn) in replacements) {
      result = result.replaceAll(en, idn);
    }
    return result;
  }
}
