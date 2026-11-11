import 'dart:convert';
import 'dart:typed_data';

import 'package:day_log/core/services/study_result_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class ClaimAdapter implements HttpClientAdapter {
  final int status;
  final requests = <RequestOptions>[];
  ClaimAdapter(this.status);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'data': {
          'session_id': 'session_saved',
          'study_date': '2026-11-10',
          'start_time': '2026-11-10T05:00:00Z',
          'end_time': '2026-11-10T05:10:00Z',
          'total_study_seconds': 540,
          'drowsiness_count': 1,
          'posture_warning_count': 0,
          'detection_logs': [
            {'time': '2026-11-10T05:05:00Z', 'type': 'drowsiness'},
          ],
        },
      }),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final origin = Uri.parse('https://seat.example');
  final id = List.filled(43, 'a').join();

  test('accepts only exact trusted result URL with a 43 character token', () {
    expect(parseStudyResultId('https://seat.example/results#$id', origin), id);
    for (final raw in [
      'https://evil.example/results#$id',
      'http://seat.example/results#$id',
      'https://seat.example:444/results#$id',
      'https://u@seat.example/results#$id',
      'https://seat.example/results/?x#$id',
      'https://seat.example/results?x#$id',
      'https://seat.example/results?#$id',
      'https://seat.example/results#a',
      'https://seat.example/results#${List.filled(43, '!').join()}',
      id,
      '{"type":"smart_seat_study_result"}',
    ]) {
      expect(
        () => parseStudyResultId(raw, origin),
        throwsFormatException,
        reason: raw,
      );
    }
  });

  test(
    'claim uses configured API, bearer, no body; repeated claim stays identical',
    () async {
      final adapter = ClaimAdapter(200);
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example/api/v1'))
        ..httpClientAdapter = adapter;
      final service = StudyResultService(dio);
      final first = await service.claim(id, 'login-token');
      final retry = await service.claim(id, 'login-token');
      expect(first.sessionId, retry.sessionId);
      expect(first.totalStudySeconds, 540);
      expect(first.detectionLogs.single.type, 'drowsiness');
      for (final request in adapter.requests) {
        expect(
          request.uri.toString(),
          'https://api.example/api/v1/me/study-results/$id/claim',
        );
        expect(request.method, 'POST');
        expect(request.data, isNull);
        expect(request.headers['Authorization'], 'Bearer login-token');
        expect(request.followRedirects, isFalse);
      }
    },
  );

  for (final status in [401, 404, 409, 410, 422, 503]) {
    test('preserves claim error $status for UI handling', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example/api/v1'))
        ..httpClientAdapter = ClaimAdapter(status);
      await expectLater(
        StudyResultService(dio).claim(id, 'token'),
        throwsA(
          isA<StudyResultException>().having((e) => e.status, 'status', status),
        ),
      );
    });
  }
}
