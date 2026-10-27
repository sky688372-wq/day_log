import 'package:day_log/core/models/login_response_model.dart';
import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/services/login_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//자동 로그인 결과
enum AutoLoginResult {
  success, //로그인 성공
  loginRequired, //직접 로그인 필요
  retryRequired, //오류로 재시도 필요
}

class UserInfoProvider extends ChangeNotifier {
  //기기에 저장된 로그인 정보 관리
  final LoginStorageService _loginStorageService = LoginStorageService();

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
    required bool isKeepLogin,
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

      try {
        //로그인 유지 체크 시 이메일과 비밀번호 저장
        if (isKeepLogin) {
          await _loginStorageService.keepLogin(
            email: email.trim(),
            password: password,
          );
        } else {
          //체크하지 않았다면 이전에 저장한 로그인 정보 삭제
          await _loginStorageService.deleteLoginInfo();
        }
      } catch (e) {
        _errorMessage = isKeepLogin
            ? '로그인 정보를 기기에 저장하지 못했어요. 다시 시도해주세요.'
            : '기기에 저장된 로그인 정보를 삭제하지 못했어요. 다시 시도해주세요.';
        return false;
      }

      //로그인 성공 시 유저 정보 보관
      _loginResponse = loginResponse;

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

  //자동 로그인 시도 함수
  Future<AutoLoginResult> autoLogin() async {
    //중복 요청 방지
    if (_isLoading) return AutoLoginResult.retryRequired;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      //기기에 저장된 이메일과 비밀번호 읽기
      final loginInfo = await _loginStorageService.readLoginInfo();

      //저장된 정보가 없다면 직접 로그인
      if (loginInfo == null) {
        _loginResponse = null;
        return AutoLoginResult.loginRequired;
      }

      final email = loginInfo['email'];
      final password = loginInfo['password'];

      //저장된 로그인 정보 확인
      if (email == null ||
          email.trim().isEmpty ||
          password == null ||
          password.isEmpty) {
        await _loginStorageService.deleteLoginInfo();
        _loginResponse = null;
        return AutoLoginResult.loginRequired;
      }

      //저장된 정보로 로그인 API 호출
      final loginResponse = await ApiService.tryLogin(
        email: email.trim(),
        password: password,
      );

      final token = loginResponse?.token;
      final userId = loginResponse?.userId;

      //서버에서 받은 로그인 정보 확인
      if (token == null ||
          token.trim().isEmpty ||
          userId == null ||
          userId.trim().isEmpty) {
        _errorMessage = '로그인 정보를 불러오지 못했어요. 다시 시도해주세요.';
        return AutoLoginResult.retryRequired;
      }

      //새로 발급받은 토큰과 유저 정보 보관
      _loginResponse = loginResponse;

      return AutoLoginResult.success;
    } on DioException catch (e) {
      //이메일 또는 비밀번호 인증 실패
      if (e.response?.statusCode == 401) {
        _loginResponse = null;

        try {
          //인증에 실패한 저장 정보 삭제
          await _loginStorageService.deleteLoginInfo();
        } catch (e) {
          _errorMessage = '저장된 로그인 정보를 삭제하지 못했어요. 다시 시도해주세요.';
          return AutoLoginResult.retryRequired;
        }

        _errorMessage = '로그인 정보가 변경되었어요. 다시 로그인해주세요.';
        return AutoLoginResult.loginRequired;
      }

      //연결 오류나 서버 오류일 때는 저장 정보를 삭제하지 않음
      _errorMessage = e.response == null
          ? '서버에 연결하지 못했어요. 연결 상태를 확인하고 다시 시도해주세요.'
          : '자동 로그인에 실패했어요. 잠시 후 다시 시도해주세요.';

      return AutoLoginResult.retryRequired;
    } catch (e) {
      //보안 저장소 접근이나 응답 처리 중 오류
      _errorMessage = '자동 로그인 처리 중 오류가 발생했어요. 다시 시도해주세요.';
      return AutoLoginResult.retryRequired;
    } finally {
      //성공하거나 실패해도 로딩 상태 해제
      _isLoading = false;
      notifyListeners();
    }
  }
}
