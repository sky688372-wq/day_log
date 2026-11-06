class Validators {
  //이메일 기본 형식 검사에 사용할 정규식
  static final RegExp _emailRegExp = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  // 1. 이메일 기본 형식 검사 : 리턴 타입은 bool
  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email.trim());
  }
}
