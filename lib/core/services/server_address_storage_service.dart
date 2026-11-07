import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//서버 주소를 보안 저장소에서 관리하는 클래스
class ServerAddressStorageService {
  //스토리지 객체
  final storage = const FlutterSecureStorage();

  //서버 주소 저장에 사용할 키
  static const String _serverAddressKey = 'server_address';

  // 1. 서버 주소 저장하기
  Future<void> saveServerAddress(String address) async {
    await storage.write(key: _serverAddressKey, value: address);
  }

  // 2. 저장된 서버 주소 읽기 (없으면 null)
  Future<String?> readServerAddress() async {
    return await storage.read(key: _serverAddressKey);
  }
}