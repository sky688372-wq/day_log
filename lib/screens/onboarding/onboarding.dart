import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/screens/onboarding/pages/habit_intro_page.dart';
import 'package:day_log/screens/onboarding/pages/qr_intro_page.dart';
import 'package:day_log/screens/onboarding/pages/study_intro_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; //스무스 페이지 인디케이터

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  //페이지 컨트롤러
  final PageController _pageController = PageController();

  //현재 페이지 상태 변수
  int _currentPage = 0;

  //다음 페이지로 넘어가는 함수
  void _nextPage() {
    if (_currentPage == 2) {
      //todo 백엔드 완료되면 로그인 상태 확인 후 홈 화면으로 이동시키기
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //각 기기의 화면 크기 저장 변수
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        surfaceTintColor: AppColor.background,
        actions: [
          //스킵 텍스트 버튼
          TextButton(
            onPressed: () {
              //todo 백엔드 완료되면 소개 건너뛰고 로그인 상태 확인 후 홈 화면으로 이동시키기
            },
            child: const Text(
              '넘어갈래요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. 소개 페이지 영역
            SizedBox(
              height: screenSize.height * 0.65,
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    //현재 페이지 변경 후 화면 리빌드
                    _currentPage = value;
                  });
                },
                children: const [
                  StudyIntroPage(),
                  HabitIntroPage(),
                  QrIntroPage(),
                ],
              ),
            ),
            

            // 2. 스무스 페이지 인데케이터
            SmoothPageIndicator(
                controller: _pageController,
                count: 3,
              effect: WormEffect(
                activeDotColor: AppColor.primaryDark,
                dotWidth: 10,
                dotHeight: 10
              ),
            ),

            const SizedBox(height: 10,),

            // 3. 다음 페이지와 시작하기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: AppColor.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _nextPage,
                child: Text(
                  _currentPage == 2 ? '시작하기' : '다음',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
