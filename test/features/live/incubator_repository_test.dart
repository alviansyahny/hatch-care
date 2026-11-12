import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/live/data/repositories/incubator_repository_impl.dart';

void main() {
  group('IncubatorRepositoryImpl (MockClient, tanpa internet asli)', () {
    test('fetchLatest format backend terbaru: image path relatif', () async {
      final repo = IncubatorRepositoryImpl(
        _mockClient(
          200,
          '{"status":"online","online":true,'
          '"image":"/incubator/photo/inc_1.jpg","url":"/incubator/photo/inc_1.jpg",'
          '"total_eggs":12,'
          '"detections":[{"confidence":0.95},{"confidence":null}],'
          '"temperature":37.6,"humidity":55.2,"lamp":true,"motor":false,'
          '"rssi":-60,"last_updated":"2026-11-12T10:00:00Z","timestamp":1762900000,'
          '"last_seen_sec":5,'
          '"history":[{"filename":"inc_0.jpg","url":"/incubator/photo/inc_0.jpg",'
          '"timestamp":1762899940,"temperature":37.5,"humidity":54.9}]}',
        ),
      );
      final snapshot = await repo.fetchLatest();
      expect(snapshot.online, isTrue);
      expect(snapshot.totalEggs, 12);
      expect(snapshot.temperature, 37.6);
      expect(snapshot.humidity, 55.2);
      expect(snapshot.detectionConfidences, [0.95, null]);
      expect(snapshot.lastCaptureAt, isNotNull);
      expect(snapshot.image.isNetwork, isTrue);
      expect(
        snapshot.image.networkUrl,
        'https://iot.walker880.my.id/incubator/photo/inc_1.jpg',
      );
      expect(snapshot.history, hasLength(1));
      expect(snapshot.history[0].temperature, 37.5);
    });

    test('fetchLatest dengan base64 data-URI', () async {
      final repo = IncubatorRepositoryImpl(
        _mockClient(
          200,
          '{"online":true,"image":"data:image/jpeg;base64,AAAA",'
          '"total_eggs":0,"detections":[]}',
        ),
      );
      final snapshot = await repo.fetchLatest();
      expect(snapshot.image.isNetwork, isFalse);
      expect(snapshot.image.base64Data, 'AAAA');
    });

    test('fetchLatest aman terhadap body bukan objek', () async {
      final repo = IncubatorRepositoryImpl(_mockClient(200, '"x"'));
      final snapshot = await repo.fetchLatest();
      expect(snapshot.online, isFalse);
      expect(snapshot.totalEggs, 0);
      expect(snapshot.image.isEmpty, isTrue);
    });

    test('kode status bukan 200 → pesan server Indonesia', () async {
      final repo = IncubatorRepositoryImpl(_mockClient(500, ''));
      await expectLater(
        repo.fetchLatest(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Server bermasalah (kode 500)'),
          ),
        ),
      );
    });

    test('fetchHistory mem-parse field history', () async {
      final repo = IncubatorRepositoryImpl(
        _mockClient(
          200,
          '{"status":"success","ttl_seconds":3600,'
          '"history":[{"url":"/incubator/photo/a.jpg","temperature":37.4}]}',
        ),
      );
      final entries = await repo.fetchHistory();
      expect(entries, hasLength(1));
      expect(entries[0].temperature, 37.4);
    });

    test('fetchHistory tanpa field history → dataTidakValid', () async {
      final repo = IncubatorRepositoryImpl(_mockClient(200, '{"x":1}'));
      await expectLater(repo.fetchHistory(), throwsA(isA<ApiException>()));
    });
  });
}

http.Client _mockClient(int statusCode, String body) {
  return MockClient((request) async {
    return http.Response(
      body,
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}
