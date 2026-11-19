import 'dart:convert';

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
          '"total_eggs":2,'
          '"detections":['
          '{"id":1,"box":[10,20,100,120],"class":"utuh","confidence":0.95},'
          '{"id":2,"box":[110,25,200,125],"class":"retak","confidence":0.88}'
          '],'
          '"detection":{"status":"success","total_eggs":2,"detections":[]},'
          '"temperature":37.6,"humidity":55.2,"lamp":true,"motor":false,'
          '"rssi":-60,"last_updated":"2026-11-12T10:00:00Z","timestamp":1762900000,'
          '"last_seen_sec":5,'
          '"history":[{"filename":"inc_0.jpg","url":"/incubator/photo/inc_0.jpg",'
          '"timestamp":1762899940,"temperature":37.5,"humidity":54.9,'
          '"detection":{"status":"success","total_eggs":1,"detections":['
          '{"id":1,"box":[1,2,30,40],"class":"retak","confidence":0.8}]}}]}',
        ),
      );
      final snapshot = await repo.fetchLatest();
      expect(snapshot.online, isTrue);
      expect(snapshot.totalEggs, 2);
      expect(snapshot.temperature, 37.6);
      expect(snapshot.humidity, 55.2);
      expect(snapshot.detectionStatus, 'success');
      expect(snapshot.detections, hasLength(2));
      expect(snapshot.detections.first.id, 1);
      expect(snapshot.detections.first.label, 'utuh');
      expect(snapshot.detections.first.confidence, 0.95);
      expect(snapshot.detections.first.x, 10);
      expect(snapshot.detections.first.y, 20);
      expect(snapshot.detections.first.width, 100);
      expect(snapshot.detections.first.height, 120);
      expect(snapshot.detections.last.isCracked, isTrue);
      expect(snapshot.crackedEggCount, 1);
      expect(snapshot.detectionConfidences, [0.95, 0.88]);
      expect(snapshot.lastCaptureAt, isNotNull);
      expect(snapshot.image.isNetwork, isTrue);
      expect(
        snapshot.image.networkUrl,
        'https://iot.walker880.my.id/incubator/photo/inc_1.jpg',
      );
      expect(snapshot.history, hasLength(1));
      expect(snapshot.history[0].temperature, 37.5);
      expect(snapshot.history[0].detectionStatus, 'success');
      expect(snapshot.history[0].totalEggs, 1);
      expect(snapshot.history[0].detections, hasLength(1));
      expect(snapshot.history[0].detections.single.isCracked, isTrue);
      expect(snapshot.history[0].detections.single.confidence, 0.8);
    });

    test('fetchLatest memakai detections dari objek detection', () async {
      final repo = IncubatorRepositoryImpl(
        _mockClient(
          200,
          '{"online":true,"image":"/incubator/photo/inc_2.jpg",'
          '"detection":{"status":"success","total_eggs":1,"detections":['
          '{"id":1,"box":[5,6,70,80],"class":"retak","confidence":0.77}]}}',
        ),
      );
      final snapshot = await repo.fetchLatest();
      expect(snapshot.detectionStatus, 'success');
      expect(snapshot.totalEggs, 1);
      expect(snapshot.detections, hasLength(1));
      expect(snapshot.detections.first.label, 'retak');
      expect(snapshot.detections.first.hasBox, isTrue);
    });

    test('fetchLatest memakai deteksi milik foto utama dari riwayat', () async {
      final repo = IncubatorRepositoryImpl(
        _mockClient(
          200,
          '{"online":true,"image":"/incubator/photo/inc_9.jpg",'
          '"total_eggs":4,'
          '"detections":['
          '{"id":1,"box":[1,1,10,10],"class":"utuh","confidence":0.9},'
          '{"id":2,"box":[2,2,10,10],"class":"utuh","confidence":0.9},'
          '{"id":3,"box":[3,3,10,10],"class":"retak","confidence":0.5},'
          '{"id":4,"box":[4,4,10,10],"class":"utuh","confidence":0.7}'
          '],'
          '"detection":{"status":"success","total_eggs":4,"photo_id":"inc_8",'
          '"detections":[{"id":1,"box":[1,1,1,1],"class":"utuh",'
          '"confidence":0.9}]},'
          '"history":[{"id":"inc_9","url":"/incubator/photo/inc_9.jpg",'
          '"detection":{"status":"success","total_eggs":2,"photo_id":"inc_9",'
          '"detections":['
          '{"id":1,"box":[10,20,30,40],"class":"utuh","confidence":0.93},'
          '{"id":2,"box":[50,60,70,80],"class":"retak","confidence":0.54}]}}]}',
        ),
      );
      final snapshot = await repo.fetchLatest();
      expect(snapshot.detectionStatus, 'success');
      expect(snapshot.totalEggs, 2);
      expect(snapshot.detections, hasLength(2));
      expect(snapshot.crackedEggCount, 1);
      expect(snapshot.history.single.id, 'inc_9');
      expect(snapshot.history.single.detectionStatus, 'success');
      expect(snapshot.history.single.totalEggs, 2);
    });

    test(
      'fetchLatest mengabaikan deteksi lama saat foto baru belum dianalisis',
      () async {
        final repo = IncubatorRepositoryImpl(
          _mockClient(
            200,
            '{"online":true,"image":"/incubator/photo/inc_10.jpg",'
            '"total_eggs":4,'
            '"detections":['
            '{"id":1,"box":[1,1,10,10],"class":"utuh","confidence":0.9}],'
            '"detection":{"status":"success","total_eggs":4,"photo_id":"inc_9"},'
            '"history":[{"id":"inc_10",'
            '"url":"/incubator/photo/inc_10.jpg"}]}',
          ),
        );
        final snapshot = await repo.fetchLatest();
        expect(snapshot.detectionStatus, isNull);
        expect(snapshot.totalEggs, 0);
        expect(snapshot.detections, isEmpty);
        expect(snapshot.image.networkUrl, endsWith('/inc_10.jpg'));
      },
    );

    test('fetchLatest tetap membaca deteksi lama tanpa box', () async {
      final repo = IncubatorRepositoryImpl(
        _mockClient(
          200,
          '{"online":true,"total_eggs":2,'
          '"detections":[{"confidence":0.95},{"confidence":null}]}',
        ),
      );
      final snapshot = await repo.fetchLatest();
      expect(snapshot.detectionConfidences, [0.95]);
      expect(snapshot.detections.first.hasBox, isFalse);
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

    test('triggerCapture POST ke /incubator/control', () async {
      late http.Request captured;
      final repo = IncubatorRepositoryImpl(
        MockClient((request) async {
          captured = request;
          return http.Response(
            '{"status":"success"}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      await repo.triggerCapture();
      expect(captured.method, 'POST');
      expect(captured.url.path, '/incubator/control');
      expect(jsonDecode(captured.body), {'triggerCapture': true});
    });

    test('triggerCapture kode status bukan 200 → ApiException', () async {
      final repo = IncubatorRepositoryImpl(_mockClient(500, ''));
      await expectLater(repo.triggerCapture(), throwsA(isA<ApiException>()));
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
