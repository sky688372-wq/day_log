import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/screens/auth/Sign_up_screen.dart';
import 'package:day_log/screens/auth/forgot_password_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController(); //이메일 컨트롤러
  final TextEditingController _passwordCtrl =
      TextEditingController(); //비밀번호 컨트롤러

  //비밀번호 보임/안보임 상태 관리 변수
  bool _isPasswordShow = false;

  //자동 로그인 기능 상태 변수
  bool _isKeepLogin = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          //키보드 등장 시 픽셀 오버 방지
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

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

                // 2. 로그인 타이틀
                const Text(
                  '로그인하고\n공부 기록을 확인해요',
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
                  '공부한 시간을 모아, 나만의 흐름을 확인해요.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: AppColor.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                //4. 이메일 입력 텍스트 필드
                // todo 나중에 백엔드 호출 최소화를 위해서 유효성 검사 해야함
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

                //5. 비밀번호 텍스트 필드
                // todo 나중에 백엔드 호출 최소화를 위해서 유효성 검사 해야함
                TextField(
                  controller: _passwordCtrl,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isPasswordShow ? false : true,
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
                        width: 2.0,
                        color: AppColor.primary,
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


                // 6. 로그인 유지 체크 박스와 비밀번호 찾기 텍스트 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 로그인 유지 체크 박스
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _isKeepLogin,
                            activeColor: AppColor.primary,
                            checkColor: AppColor.onPrimary,
                            side: const BorderSide(
                              color: AppColor.outlineVariant,
                            ),
                            visualDensity: VisualDensity.compact,
                            onChanged: (value) {
                              setState(() {
                                //체크 상태 변경 후 화면 리빌드
                                _isKeepLogin = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            '로그인 유지',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // 비밀번호 찾기 텍스트 버튼
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primary,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),



                // 7. 로그인 버튼
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
                    // todo 로그인 처리 로직 완성되면 넣기
                  },
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.onPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 8. 회원 가입 화면 이동 텍스트 버튼
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      const Text(
                        '아직 오늘로그 계정이 없나요?',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '회원가입',
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
      bottomNavigationBar: SafeArea(
        // 어느 기기든 핸드폰 맨 아래에 위치하도록 SafeArea
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 9. 이용약관과 개인정보 처리방침
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.textSecondary,
                    ),
                    onPressed: () {
                      // todo 이용약관 페이지 만들면 이동 로직 추가하기
                    },
                    child: const Text('이용약관', style: TextStyle(fontSize: 11)),
                  ),
                  const Text('·', style: TextStyle(color: AppColor.textHint)),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.textSecondary,
                    ),
                    onPressed: () {
                      // todo 개인정보 처리방침 페이지 만들면 이동 로직 추가하기
                    },
                    child: const Text(
                      '개인정보 처리방침',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
