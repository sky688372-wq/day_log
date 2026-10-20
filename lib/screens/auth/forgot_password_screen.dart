import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController(); //이메일 컨트롤러

  @override
  void dispose() {
    _emailCtrl.dispose();
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

                // 2. 비밀번호 찾기 타이틀
                const Text(
                  '비밀번호를\n잊으셨나요?',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 14),

                // 3. 비밀번호 재설정 안내 문구
                const Text(
                  '가입한 이메일을 입력해주세요.\n비밀번호 재설정 안내를 보내드릴게요.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: AppColor.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // 4. 이메일 입력 텍스트 필드
                // todo 나중에 백엔드 호출 최소화를 위해서 유효성 검사 해야함
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: AppColor.primary,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: '가입한 이메일을 입력해주세요',
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

                const SizedBox(height: 28),

                // 5. 비밀번호 재설정 안내 보내기 버튼
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
                    // todo 이메일을 입력했는지 확인 하기
                    // todo 이메일 유효성 검사 하기
                    // todo API로 비밀번호 재설정 메일 요청 하기
                    // todo 요청 중에는 버튼 중복 클릭 막기
                    // todo 요청 성공하면 안내 문구 보여주기
                    // todo 요청 실패하면 오류 문구 보여주기

                    // todo 이건 백엔드의 여견에 따라서 다를 수 있음
                  },
                  child: const Text(
                    '재설정 안내 보내기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.onPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 6. 로그인 화면으로 돌아가기
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.primary,
                    ),
                    onPressed: () {
                      //이전 로그인 화면으로 이동
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '로그인 화면으로 돌아가기',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
