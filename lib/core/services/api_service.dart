import 'package:day_log/core/models/daily_statistics_model.dart';
import 'package:day_log/core/models/login_response_model.dart';
import 'package:day_log/core/models/statistics_model.dart';
import 'package:dio/dio.dart';

class ApiService {
  // 앱에서 공통으로 사용하는 Dio 객체
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: '$defaultServerAddress/api/v1',
      headers: {'Content-Type': 'application/json'},
      receiveTimeout: const Duration(seconds: 4),
      connectTimeout: const Duration(seconds: 4),
    ),
  );

  // 개발자 모드를 위한 부분
  // 서버 주소 기본값 (개발자 모드에서 변경 가능)
  static const String defaultServerAddress = String.fromEnvironment(
    'API_SERVER_ADDRESS', defaultValue: 'http://10.0.2.2:8000');
  static const String resultWebOrigin = String.fromEnvironment('RESULT_WEB_ORIGIN');
  static const String _apiPath = '/api/v1';

  // 서버 주소 변경 (이후 모든 요청에 적용됨)
  static void changeServerAddress(String address) {
    dio.options.baseUrl = '$address$_apiPath';
  }

  // 1. 로그인 로직
  static Future<LoginResponseModel?> tryLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('오류 코드: ${e.response?.statusCode}');
      print('오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('연결 오류: ${e.message}');
      }

      return null;
    }
  }

  // 2. 회원 가입 로직
  static Future<bool> trySignUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
        },
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      print('회원가입 오류 유형: ${e.type}');
      print('회원가입 오류 코드: ${e.response?.statusCode}');
      print('회원가입 오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('서버 연결 오류: ${e.message}');
      }

      return false;
    }
  }

  // 3. 일별 통계 조회 로직
  static Future<DailyStatisticsModel?> tryGetDailyStatistics({
    required String token,
    required DateTime date,
  }) async {
    try {
      final response = await dio.get(
        '/me/statistics/daily',
        queryParameters: {
          'date': _dateText(date),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return DailyStatisticsModel.fromJson(response.data);
    } on DioException catch (e) {
      print('일별 통계 오류 코드: ${e.response?.statusCode}');
      print('일별 통계 오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('연결 오류: ${e.message}');
      }

      return null;
    } catch (e) {
      print('일별 통계 처리 오류: $e');
      return null;
    }
  }

  // 4. 월별 통계 조회 로직
  static Future<MonthlyStatisticsModel?> tryGetMonthlyStatistics({
    required String token,
    required DateTime month,
  }) async {
    try {
      final monthText =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      final response = await dio.get(
        '/me/statistics/monthly',
        queryParameters: {
          'month': monthText,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return MonthlyStatisticsModel.fromJson(response.data);
    } on DioException catch (e) {
      print('월별 통계 오류 코드: ${e.response?.statusCode}');
      print('월별 통계 오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('연결 오류: ${e.message}');
      }

      return null;
    } catch (e) {
      print('월별 통계 처리 오류: $e');
      return null;
    }
  }

  // 5. 주별 통계 조회 로직
  static Future<WeeklyStatisticsModel?> tryGetWeeklyStatistics({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await dio.get(
        '/me/statistics/weekly',
        queryParameters: {
          'start_date': _dateText(startDate),
          'end_date': _dateText(endDate),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return WeeklyStatisticsModel.fromJson(response.data);
    } on DioException catch (e) {
      print('주별 통계 오류 코드: ${e.response?.statusCode}');
      print('주별 통계 오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('연결 오류: ${e.message}');
      }

      return null;
    } catch (e) {
      print('주별 통계 처리 오류: $e');
      return null;
    }
  }

  // 6. 서버 요청용 날짜 형식
  static String _dateText(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}