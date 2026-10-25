import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';

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

    //todo 자동 로그인 확인 후 결과에 따라 화면 이동하기 -> 응답 받을 동안 대기해두도록
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
