import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//로그인 유지에 필요한 정보를 보안 저장소에서 관리하는 클래스
class LoginStorageService {
  //스토리지 객체
  final storage = const FlutterSecureStorage();

  //로그인 정보 저장에 사용할 키
  static const String _loginInfoKey = 'login_credentials';

  // 1. 로컬에 로그인 정보 저장하기
  Future<void> keepLogin({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const FormatException('저장할 로그인 정보가 올바르지 않습니다.');
    }

    final loginInfo = {
      'email': email.trim(),
      'password': password,
    };

    await storage.write(
      key: _loginInfoKey,
      value: jsonEncode(loginInfo),
    );
  }

  // 2. 로컬에 저장된 로그인 정보 읽기
  Future<Map<String, String>?> readLoginInfo() async {
    final savedInfo = await storage.read(
      key: _loginInfoKey,
    );

    //저장된 정보가 없다면 null 반환
    if (savedInfo == null) return null;

    try {
      final loginInfo = jsonDecode(savedInfo);

      //저장된 데이터 형식 확인
      if (loginInfo is! Map<String, dynamic>) {
        throw const FormatException('저장된 로그인 정보가 올바르지 않습니다.');
      }

      final email = loginInfo['email'];
      final password = loginInfo['password'];

      if (email is! String ||
          email.trim().isEmpty ||
          password is! String ||
          password.isEmpty) {
        throw const FormatException('저장된 로그인 정보가 올바르지 않습니다.');
      }

      return {
        'email': email,
        'password': password,
      };
    } on FormatException {
      //손상된 로그인 정보는 삭제
      await deleteLoginInfo();
      return null;
    }
  }

  // 3. 로컬에 저장된 로그인 정보 삭제하기
  Future<void> deleteLoginInfo() async {
    await storage.delete(
      key: _loginInfoKey,
    );
  }
}
