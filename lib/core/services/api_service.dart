import 'package:day_log/core/models/daily_statistics_model.dart';
import 'package:day_log/core/models/login_response_model.dart';
import 'package:dio/dio.dart';

class ApiService {
  //dio 객체 : 서버가 여러 개가 있는 것이 아니라 디오 클라이언트는 필요 없음
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1',
      headers: {'Content-Type': 'application/json'},
      receiveTimeout: Duration(seconds: 4), // 데이터를 받아오는 제한 시간
      connectTimeout: Duration(seconds: 4), // 연결 제한 시간
    ),
  );

  // 1. 로그인 로직
  // todo 앱 다 만든 후에 이메일 정규식으로 유효성 검사 등을 추가해서 서버에 요청 횟수를 최대한 줄이기
  static Future<LoginResponseModel?> tryLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {"email": email, "password": password},
      );

      // 성공 시 받아온 데이터를 확인하기 위한 출력문
      // print('로그인 성공: ${response.statusCode}');
      // print('받아온 데이터 : \n${response.data}');

      // todo 응답에서 토큰 받아서 저장하기하고 값 반환
      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      //오류 날때만 출력해서 나중에 전시할 때 오류 생기면 바로 수정 가능하도록
      print('오류 코드: ${e.response?.statusCode}');
      print('오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('연결 오류: ${e.message}');
      }
      return null;
    }
  }

  // 2. 회원 가입 로직
  // todo 앱 다 만든 후에 이메일 정규식으로 유효성 검사 등을 추가해서 서버에 요청 횟수를 최대한 줄이기
  static Future<bool> trySignUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      //회원가입 요청
      final response = await dio.post(
        '/auth/register',
        data: {
          "email": email.trim(),
          "password": password,
          "name": name.trim(),
        },
      );

      if (response.statusCode == 201) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      //실패 원인 확인용 출력문
      print('회원가입 오류 유형: ${e.type}');
      print('회원가입 오류 코드: ${e.response?.statusCode}');

      //개발 중 원인 확인용으로만 사용
      //서버 응답에 개인정보가 포함될 수 있으므로 확인용
      print('회원가입 오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('서버 연결 오류: ${e.message}');
      }

      return false;
    }
  }

  // 3. 일별 통계 조회 로직 todo 최종 확인 된다면 프론트 구문들 주석 처리하기
  static Future<DailyStatisticsModel?> tryGetDailyStatistics({
    required String token,
    required DateTime date,
  }) async {
    try {
      // 서버가 요구하는 YYYY-MM-DD 형식으로 변환
      final dateText =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await dio.get(
        '/me/statistics/daily',
        queryParameters: {'date': dateText},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );


      print('일별 통계 성공: ${response.statusCode}');
      print('일별 통계 응답: ${response.data}');

      return DailyStatisticsModel.fromJson(response.data);
    } on DioException catch (e) {
      print('일별 통계 오류 코드: ${e.response?.statusCode}');
      print('일별 통계 오류 응답: ${e.response?.data}');

      if (e.response == null) {
        print('연결 오류: ${e.message}');
      }
      return null;
    } catch (e) {
      // 응답을 모델로 변환하는 과정 등에서 발생한 오류
      print('일별 통계 처리 오류: $e');
      return null;
    }
  }
}
