import 'package:day_log/core/models/login_response_model.dart';
import 'package:day_log/core/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {
  //로그인한 유저 정보
  LoginResponseModel? _loginResponse;

  //로그인 요청 상태 변수
  bool _isLoading = false;

  //로그인 실패 메시지
  String? _errorMessage;

  //외부에서 확인할 수 있도록 getter
  LoginResponseModel? get loginResponse => _loginResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //로그인 여부 확인
  bool get isLoggedIn => _loginResponse != null;

  //로그인 시도 함수
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    //중복 요청 방지
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginResponse = await ApiService.tryLogin(
        email: email.trim(),
        password: password,
      );

      final token = loginResponse?.token;
      final userId = loginResponse?.userId;

      //로그인에 필요한 데이터 확인
      if (token == null ||
          token.trim().isEmpty ||
          userId == null ||
          userId.trim().isEmpty) {
        _errorMessage = '로그인 정보를 불러오지 못했어요. 다시 시도해주세요.';
        return false;
      }

      //로그인 성공 시 유저 정보 보관
      _loginResponse = loginResponse;

      //todo 로그인 유지 여부에 따라 토큰을 보안 저장소에 저장하기

      return true;
    } on DioException catch (e) {
      _errorMessage = e.response == null
          ? '서버에 연결하지 못했어요. 잠시 후 다시 시도해주세요.'
          : '로그인에 실패했어요. 다시 시도해주세요.';

      //서버에서 보내준 오류 메시지 확인
      final data = e.response?.data;

      if (data is Map) {
        final error = data['error'];

        if (error is Map && error['message'] is String) {
          _errorMessage = error['message'] as String;
        }
      }

      return false;
    } catch (e) {
      //응답을 모델로 변환하는 과정 등에서 오류가 발생한 경우
      _errorMessage = '로그인 처리 중 오류가 발생했어요. 다시 시도해주세요.';
      return false;
    } finally {
      //성공하거나 실패해도 로딩 상태 해제
      _isLoading = false;
      notifyListeners();
    }
  }
}
