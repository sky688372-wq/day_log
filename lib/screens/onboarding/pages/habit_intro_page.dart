import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class HabitIntroPage extends StatelessWidget {
  const HabitIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    //각 기기의 화면 크기 저장 변수
    final screenSize = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 1. 공부 습관 소개 이미지
            //todo Storyset 일러스트 출처는 앱 출처 안내에 표기하기
            Image.asset(
              'assets/images/Analytics-rafiki.png',
              height: screenSize.height * 0.35,
              width: screenSize.width * 0.8,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 28),

            // 2. 공부 습관 소개 제목
            const Text(
              '시간 너머, 공부 습관까지',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
                letterSpacing: -0.7,
              ),
            ),

            const SizedBox(height: 14),

            // 3. 공부 습관 소개 문구
            const Text(
              '공부 중 졸음과 자세 경고가 발생한 순간을\n확인하고, 나의 학습 습관을 돌아봐요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
