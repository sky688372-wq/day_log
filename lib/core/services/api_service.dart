import 'package:day_log/core/models/login_response_model.dart';
import 'package:dio/dio.dart';

class ApiService {
  //dio 객체
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1',
      headers: {'Content-Type': 'application/json'},
      receiveTimeout: Duration(seconds: 4), // 데이터를 받아오는 제한 시간
      connectTimeout: Duration(seconds: 4), // 연결 제한 시간
    ),
  );

  // 로그인 로직
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
}
