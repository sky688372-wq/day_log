import 'package:day_log/core/providers/user_info_provider.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/screens/auth/login_screen.dart';
import 'package:day_log/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  //애니메이션 컨트롤러
  late final AnimationController _animationController;

  //투명도 애니메이션
  late final Animation<double> _fadeAnimation;

  //크기 애니메이션
  late final Animation<double> _scaleAnimation;

  //자동 로그인 확인 상태
  bool _isChecking = true;

  //자동 로그인 오류 메시지
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    //애니메이션 시작
    _animationController.forward();

    //첫 화면이 그려진 뒤 자동 로그인 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAutoLogin();
    });
  }

  //자동 로그인 확인 후 화면 이동
  Future<void> _checkAutoLogin() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final userInfoProvider = context.read<UserInfoProvider>();

    //애니메이션 표시 시간과 자동 로그인 확인을 함께 진행
    final animationWait = Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    final result = await userInfoProvider.autoLogin();

    await animationWait;

    //비동기 작업 중 화면을 나갔다면 처리 중단
    if (!mounted) return;

    if (result == AutoLoginResult.success) {
      //로그인 성공 시 하단 탭을 관리하는 메인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } else if (result == AutoLoginResult.loginRequired) {
      //저장 정보가 없거나 인증에 실패하면 로그인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } else {
      //연결 오류 등은 저장 정보를 유지하고 재시도 안내
      setState(() {
        _isChecking = false;
        _errorMessage = userInfoProvider.errorMessage ??
            '자동 로그인에 실패했어요. 다시 시도해주세요.';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //앱 아이콘
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    //앱 이름
                    const Text(
                      'Daylog',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                        letterSpacing: -0.7,
                      ),
                    ),

                    const SizedBox(height: 10),

                    //앱 소개 문구
                    const Text(
                      '오늘의 공부를 차곡차곡',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColor.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    //자동 로그인 확인 중 표시
                    if (_isChecking)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColor.primary,
                          strokeWidth: 2,
                        ),
                      ),

                    //자동 로그인 오류 시 안내와 재시도 버튼
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primary,
                        ),
                        onPressed: _checkAutoLogin,
                        child: const Text('다시 시도'),
                      ),

                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.textSecondary,
                        ),
                        onPressed: () {
                          //저장 정보는 유지한 채 직접 로그인 화면으로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('직접 로그인'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
