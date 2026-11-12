import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  group('AuthRepositoryImpl (MockClient, tanpa internet asli)', () {
    test(
      'register mengirim data dan mengembalikan user + token',
      () async {
        final repo = AuthRepositoryImpl(
          _mockClient(
            201,
            '{"user":{"id":1,"name":"Alvia","username":"alvia",'
            '"email":"alvia@test.com"},"token":"1|abc"}',
            expectPost: true,
            expectPath: '/api/register',
            expectBodyContains: ['"username":"alvia"', '"email":"alvia@test.com"'],
          ),
        );
        final session = await repo.register(
          name: 'Alvia',
          username: 'alvia',
          email: 'alvia@test.com',
          password: 'password123',
        );
        expect(session.token, '1|abc');
        expect(session.user.id, 1);
        expect(session.user.username, 'alvia');
      },
    );

    test('login via username mengembalikan user + token', () async {
      final repo = AuthRepositoryImpl(
        _mockClient(
          200,
          '{"user":{"id":2,"name":"Budi","username":"budi",'
          '"email":"budi@test.com"},"token":"2|def"}',
          expectPost: true,
          expectPath: '/api/login',
          expectBodyContains: ['"login":"budi"'],
        ),
      );
      final session = await repo.login(login: 'budi', password: 'rahasia');
      expect(session.token, '2|def');
      expect(session.user.email, 'budi@test.com');
    });

    test(
      'login dengan kredensial salah → pesan validasi 422',
      () async {
        final repo = AuthRepositoryImpl(
          _mockClient(
            422,
            '{"message":"The login field is required.","errors":'
            '{"login":["The login field is required."]}}',
          ),
        );
        await expectLater(
          repo.login(login: '', password: ''),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 422)
                .having(
                  (e) => e.message,
                  'message',
                  'Username atau email wajib diisi.',
                ),
          ),
        );
      },
    );

    test('register dengan email terpakai → pesan sudah digunakan', () async {
      final repo = AuthRepositoryImpl(
        _mockClient(
          422,
          '{"message":"The email has already been taken.","errors":'
          '{"email":["The email has already been taken."]}}',
        ),
      );
      await expectLater(
        repo.register(
          name: 'a',
          username: 'a',
          email: 'alvia@test.com',
          password: 'password123',
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Email sudah digunakan.',
          ),
        ),
      );
    });

    test('me mengirim header Bearer dan mem-parse user', () async {
      final repo = AuthRepositoryImpl(
        _mockClient(
          200,
          '{"user":{"id":1,"name":"Alvia","username":"alvia",'
          '"email":"alvia@test.com"}}',
          expectPath: '/api/user',
          expectHeader: const ('authorization', 'Bearer 1|abc'),
        ),
      );
      final user = await repo.me(token: '1|abc');
      expect(user.id, 1);
      expect(user.name, 'Alvia');
    });

    test('logout mengirim header Bearer', () async {
      final repo = AuthRepositoryImpl(
        _mockClient(
          200,
          '{"message":"Berhasil keluar."}',
          expectPost: true,
          expectPath: '/api/logout',
          expectHeader: const ('authorization', 'Bearer 1|abc'),
        ),
      );
      await repo.logout(token: '1|abc');
    });

    test('server 500 → pesan serverError', () async {
      final repo = AuthRepositoryImpl(_mockClient(500, ''));
      await expectLater(
        repo.login(login: 'budi', password: 'x'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Server bermasalah (kode 500)'),
          ),
        ),
      );
    });
  });
}

http.Client _mockClient(
  int statusCode,
  String body, {
  bool expectPost = false,
  String? expectPath,
  List<String> expectBodyContains = const [],
  (String, String)? expectHeader,
}) {
  return MockClient((request) async {
    if (expectPost) expect(request.method, 'POST');
    if (expectPath != null) {
      expect(request.url.path, endsWith(expectPath));
    }
    for (final fragment in expectBodyContains) {
      expect(request.body, contains(fragment));
    }
    if (expectHeader != null) {
      expect(
        request.headers[expectHeader.$1],
        expectHeader.$2,
        reason: 'Header ${expectHeader.$1} harus terkirim',
      );
    }
    return http.Response(
      body,
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}
