import 'package:day_log/core/theme/app_color.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                // todo 나중에 이메일 유효성 검사와 중복 확인 해야함
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: '이메일을 입력해주세요',
                    hintStyle: const TextStyle(color: AppColor.textHint),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.alternate_email,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
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
                // todo 나중에 비밀번호 유효성 검사 해야함
                TextField(
                  controller: _passwordCtrl,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isPasswordShow ? false : true,
                  autocorrect: false,
                  enableSuggestions: false,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    hintStyle: const TextStyle(color: AppColor.textHint),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
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
                // todo 나중에 입력한 비밀번호와 같은지 확인 해야함
                TextField(
                  controller: _passwordCheckCtrl,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isPasswordCheckShow ? false : true,
                  autocorrect: false,
                  enableSuggestions: false,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: '비밀번호를 다시 입력해주세요',
                    hintStyle: const TextStyle(color: AppColor.textHint),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
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
                // todo 나중에 이름 유효성 검사 해야함
                TextField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: '앱에서 사용할 이름을 입력해주세요',
                    hintStyle: const TextStyle(color: AppColor.textHint),
                    filled: true,
                    fillColor: AppColor.surfaceCard,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColor.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.outline),
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
                  onPressed: () {
                    // todo 입력한 정보 유효성 검사 하기
                    // todo 비밀번호와 비밀번호 확인이 같은지 확인 하기
                    // todo API로 이메일, 비밀번호, 이름 보내서 회원가입 처리 하기
                    // todo 회원가입 성공하면 로그인 화면으로 이동하기
                    // todo 회원가입 실패하면 오류 문구 보여주기
                  },
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.onPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                //9. 계정이 있다면 다시 뒤로 pop시키는 텍스트 버튼
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
                          //이전 페이지(로그인 페이지로 이동)
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
