import 'package:day_log/core/models/study_session_model.dart';
import 'package:dio/dio.dart';

/// Only the configured seat website may supply result IDs. Never use a scanned
/// URL as an API destination or send login credentials to it.
String parseStudyResultId(String raw, Uri trustedOrigin) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      uri.origin != trustedOrigin.origin ||
      uri.userInfo.isNotEmpty ||
      uri.path != '/results' ||
      uri.hasQuery ||
      !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(uri.fragment)) {
    throw const FormatException('스마트 좌석 결과 QR이 아닙니다.');
  }
  return uri.fragment;
}

class StudyResultException implements Exception {
  final int? status;
  const StudyResultException(this.status);

  String get message => switch (status) {
    401 => '로그인이 필요해요. 로그인 후 같은 QR 저장을 이어갑니다.',
    404 => '존재하지 않거나 정리된 결과예요.',
    409 => '이미 다른 계정에 저장된 결과예요.',
    410 => '만료되거나 사용된 QR이에요. 저장한 기록은 통계에서 확인해주세요.',
    422 => '올바른 학습 결과 QR인지 확인해주세요.',
    _ => '기록을 확인하지 못했어요. 같은 결과로 다시 시도해주세요.',
  };
}

class StudyResultService {
  final Dio dio;
  StudyResultService(this.dio);

  Future<StudySessionModel> claim(String resultId, String token) async {
    if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(resultId)) {
      throw const StudyResultException(422);
    }
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/me/study-results/$resultId/claim',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(seconds: 15),
          followRedirects: false,
        ),
      );
      return StudySessionModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw StudyResultException(error.response?.statusCode);
    } catch (_) {
      // A malformed success response may follow a committed save. Retrying the
      // same claim is safe; creating a separate session would duplicate it.
      throw const StudyResultException(null);
    }
  }
}
