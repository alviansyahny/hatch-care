import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/egg_check/data/repositories/egg_check_repository_impl.dart';
import 'package:hatch_care/features/egg_check/domain/models/candling_job_models.dart';

void main() {
  group('EggCheckRepositoryImpl (MockClient, tanpa internet asli)', () {
    test(
      'fetchDeviceStatus mem-parse field online/rssi/last_seen_sec',
      () async {
        final repo = EggCheckRepositoryImpl(
          _mockClient(200, '{"online":true,"rssi":-52,"last_seen_sec":4}'),
        );
        final status = await repo.fetchDeviceStatus();
        expect(status.online, isTrue);
        expect(status.rssi, -52);
        expect(status.lastSeenSec, 4);
      },
    );

    test('fetchDeviceStatus aman terhadap field hilang', () async {
      final repo = EggCheckRepositoryImpl(_mockClient(200, '{}'));
      final status = await repo.fetchDeviceStatus();
      expect(status.online, isFalse);
      expect(status.rssi, isNull);
    });

    test('kode status bukan 200 → pesan server Indonesia', () async {
      final repo = EggCheckRepositoryImpl(_mockClient(503, ''));
      await expectLater(
        repo.fetchDeviceStatus(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Server bermasalah (kode 503)'),
          ),
        ),
      );
    });

    test('requestCapture mengembalikan id job', () async {
      final repo = EggCheckRepositoryImpl(
        _mockClient(200, '{"job":7}', expectPost: true),
      );
      final jobId = await repo.requestCapture(
        const CaptureParams(exposure: 500, gain: 0, quality: 6, settleMs: 250),
      );
      expect(jobId, 7);
    });

    test('requestCapture tanpa field job → dataTidakValid', () async {
      final repo = EggCheckRepositoryImpl(_mockClient(200, '{"x":1}'));
      await expectLater(
        repo.requestCapture(const CaptureParams()),
        throwsA(isA<ApiException>()),
      );
    });

    test('fetchJobDetail mem-parse prediksi & tahapan CV', () async {
      final body = '''
      {
        "status": "done",
        "url": "data:image/jpeg;base64,AAAA",
        "prediction_label": "fertil",
        "confidence": 0.93,
        "llm_analysis": "Telur tampak fertil.",
        "prediction_result": {
          "label": "fertil",
          "keyakinan": 0.93,
          "probabilitas": {"fertil": 0.9, "infertil": 0.05, "mortal": 0.05},
          "visualisasi": {"citra_crop": "AAAA", "citra_biner_roi": "BBBB"}
        }
      }''';
      final repo = EggCheckRepositoryImpl(_mockClient(200, body));
      final detail = await repo.fetchJobDetail(1);
      expect(detail.status, 'done');
      expect(detail.label, 'fertil');
      expect(detail.confidence, 0.93);
      expect(detail.llmAnalysis, 'Telur tampak fertil.');
      expect(detail.probabilities['fertil'], 0.9);
      expect(detail.stages, hasLength(2));
      expect(detail.stages[0].title, 'Crop Telur');
    });

    test('fetchCaptureHistory melewati item tanpa id', () async {
      final body = '''
      [
        {"id": 3, "url": "AAAA", "prediction_label": "fertil"},
        {"url": "BBBB"},
        {"id": 1, "url": "CCCC", "prediction_label": "mortal"}
      ]''';
      final repo = EggCheckRepositoryImpl(_mockClient(200, body));
      final items = await repo.fetchCaptureHistory();
      expect(items, hasLength(2));
      expect(items[0].id, 3);
      expect(items[1].label, 'mortal');
    });
  });
}

http.Client _mockClient(
  int statusCode,
  String body, {
  bool expectPost = false,
}) {
  return MockClient((request) async {
    if (expectPost) {
      expect(request.method, 'POST');
      expect(request.body, contains('exposure'));
    }
    return http.Response(
      body,
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}
