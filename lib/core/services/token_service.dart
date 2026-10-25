import 'dart:convert';

import 'package:day_log/core/models/login_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 로컬에 있는 토큰을 관리할 수 있도록 하는 클래스
class TokenService { // todo 토큰으로 말고 로그인 정보(이메일과 비밀번호)를 직접 저장하도록 하기 -> 내 정보 조회 등의 API가 없음
  //스토리지 객체
  final storage = const FlutterSecureStorage();

  //로그인 정보 저장에 사용할 키
  static const String _loginInfoKey = 'login_info';

  // 1. 로컬에 로그인 정보 저장하기
  Future<void> keepLogin({
    required LoginResponseModel loginResponse,
  }) async {
    final token = loginResponse.token;
    final userId = loginResponse.userId;
    final expiresIn = loginResponse.expiresIn;

    //저장에 필요한 정보 확인
    if (token == null ||
        token.trim().isEmpty ||
        userId == null ||
        userId.trim().isEmpty ||
        expiresIn == null ||
        expiresIn <= 0) {
      throw const FormatException('저장할 로그인 정보가 올바르지 않습니다.');
    }

    //토큰 만료 시각 계산
    final expiresAt = DateTime.now().toUtc().add(
      Duration(seconds: expiresIn),
    );

    //로그인 정보와 만료 시각을 함께 저장
    final loginInfo = {
      'data': {
        'access_token': token,
        'token_type': loginResponse.tokenType,
        'expires_in': expiresIn,
        'user': {
          'user_id': userId,
          'name': loginResponse.name,
        },
      },
      'expires_at': expiresAt.toIso8601String(),
    };

    await storage.write(
      key: _loginInfoKey,
      value: jsonEncode(loginInfo),
    );
  }

  // 2. 로컬에 저장된 로그인 정보 읽기
  Future<Map<String, dynamic>?> readLoginInfo() async {
    final savedInfo = await storage.read(
      key: _loginInfoKey,
    );

    //저장된 정보가 없다면 null 반환
    if (savedInfo == null) return null;

    return jsonDecode(savedInfo) as Map<String, dynamic>;
  }

  // 3. 로컬에 저장된 로그인 정보 삭제하기
  Future<void> deleteLoginInfo() async {
    await storage.delete(
      key: _loginInfoKey,
    );
  }
}
