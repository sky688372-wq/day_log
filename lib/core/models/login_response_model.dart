class LoginResponseModel {
  // 로그인 성공 시 받는 모델
  final String? token; // 토큰
  final String? tokenType; // 토큰 타입
  final int? expiresIn; // 토큰 유효 기간(초)
  final String? userId; // 유저 아이디
  final String? name; // 유저 이름

  // 일반 생성자
  LoginResponseModel({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.name,
  });

  //팩토리 생성자
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['data']?['access_token'] as String?,
      tokenType: json['data']?['token_type'] as String?,
      expiresIn: json['data']?['expires_in'] as int?,
      userId: json['data']?['user']?['user_id'] as String?,
      name: json['data']?['user']?['name'] as String?,
    );
  }
}
