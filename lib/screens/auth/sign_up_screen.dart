import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/core/utils/snack_bar_helper.dart';
import 'package:day_log/core/utils/validators.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailCtrl = TextEditingController(); //이메일 컨트롤러
  final TextEditingController _passwordCtrl =
  TextEditingController(); //비밀번호 컨트롤러
  final TextEditingController _passwordCheckCtrl =
  TextEditingController(); //비밀번호 확인 컨트롤러
  final TextEditingController _nameCtrl = TextEditingController(); //이름 컨트롤러

  //비밀번호 보임/안보임 상태 관리 변수
  bool _isPasswordShow = false;
  bool _isPasswordCheckShow = false;

  //회원가입 요청 상태
  bool _isLoading = false;

  // 회원 가입 함수
  Future<void> tryResister() async {
    // 1. 중복 요청 방지
    if (_isLoading) return;

    // 2. 입력값 읽기
    final String email = _emailCtrl.text.trim();
    final String password = _passwordCtrl.text;
    final String passwordCheck = _passwordCheckCtrl.text;
    final String name = _nameCtrl.text.trim();

    // 3. 이메일 입력 여부 및 형식 검사
    if (email.isEmpty) {
      SnackBarHelper.show(context, '이메일을 입력해주세요.');
      return;
    }

    if (!Validators.isValidEmail(email)) {
      SnackBarHelper.show(context, '올바른 이메일 형식을 입력해주세요.');
      return;
    }

    // 4. 비밀번호 입력 여부 검사
    if (password.isEmpty) {
      SnackBarHelper.show(context, '비밀번호를 입력해주세요.');
      return;
    }

    //todo 서버 정책에 맞춰 비밀번호 생성 규칙 검사 추가하기

    // 5. 비밀번호 확인 입력 여부 및 일치 검사
    if (passwordCheck.isEmpty) {
      SnackBarHelper.show(context, '비밀번호 확인을 입력해주세요.');
      return;
    }

    if (password != passwordCheck) {
      SnackBarHelper.show(context, '비밀번호와 비밀번호 확인이 일치하지 않습니다.');
      return;
    }

    // 6. 이름 입력 여부 검사
    if (name.isEmpty) {
      SnackBarHelper.show(context, '앱에서 사용할 이름을 입력해주세요.');
      return;
    }

    //todo 이름 길이 등 추가 규칙은 서버 정책 확인 후 적용하기

    // 7. 유효성 검사를 통과하면 회원가입 요청
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.trySignUp(
        email: email,
        password: password,
        name: name,
      );

      //요청 중 화면을 나갔다면 이후 화면 처리 중단
      if (!mounted) return;

      // 8. 회원가입 결과 처리
      if (response) {
        SnackBarHelper.show(context, '회원가입에 성공하셨습니다.');

        //이전 페이지인 로그인 화면으로 이동
        Navigator.pop(context);
      } else {
        SnackBarHelper.show(
          context,
          '회원가입에 실패했습니다. 입력 정보와 서버 연결을 확인해주세요.',
        );
      }
    } finally {
      // 9. 요청이 끝나면 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordCheckCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
        surfaceTintColor: AppColor.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          //버츄얼 키보드 등장 시에 픽셀 오버 안나도록ㅇㅇㅇ
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 상단 앱 아이콘과 이름
                Row(
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Daylog',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. 회원가입 타이틀
                const Text(
                  '회원가입하고\n오늘의 공부를 기록해요',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 14),

                // 3. 앱 소개 문구
                const Text(
                  '오늘로그와 함께 나만의 공부 흐름을 만들어봐요.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // 4. 이메일 입력 텍스트 필드
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '이메일을 입력해주세요',
                    hintStyle: const TextStyle(
                      color: AppColor.textHint,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.alternate_email,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. 비밀번호 입력 텍스트 필드
                TextField(
                  controller: _passwordCtrl,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isPasswordShow ? false : true,
                  autocorrect: false,
                  enableSuggestions: false,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    hintStyle: const TextStyle(
                      color: AppColor.textHint,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.primary,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          //상태 변수 변경 후 화면 리빌드
                          _isPasswordShow = !_isPasswordShow;
                        });
                      },
                      icon: Icon(
                        _isPasswordShow
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 6. 비밀번호 확인 텍스트 필드
                TextField(
                  controller: _passwordCheckCtrl,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isPasswordCheckShow ? false : true,
                  autocorrect: false,
                  enableSuggestions: false,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '비밀번호를 다시 입력해주세요',
                    hintStyle: const TextStyle(
                      color: AppColor.textHint,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.primary,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          //상태 변수 변경 후 화면 리빌드
                          _isPasswordCheckShow = !_isPasswordCheckShow;
                        });
                      },
                      icon: Icon(
                        _isPasswordCheckShow
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 7. 앱에서 사용할 이름 텍스트 필드
                TextField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '앱에서 사용할 이름을 입력해주세요',
                    hintStyle: const TextStyle(
                      color: AppColor.textHint,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 8. 회원가입 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  //요청 중에는 버튼 비활성화
                  onPressed: _isLoading
                      ? null
                      : () {
                    tryResister();
                  },
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.primary,
                    ),
                  )
                      : const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 9. 계정이 있다면 다시 뒤로 pop시키는 텍스트 버튼
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      const Text(
                        '오늘로그 계정이 있으신가요?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primary,
                        ),
                        onPressed: () {
                          //이전 페이지인 로그인 페이지로 이동
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
