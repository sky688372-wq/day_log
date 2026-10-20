import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class StudyIntroPage extends StatelessWidget {
  const StudyIntroPage({super.key});

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
            // 1. 공부 기록 소개 이미지
            Image.asset(
              'assets/images/Studying-rafiki.png',
              height: screenSize.height * 0.35,
              width: screenSize.width * 0.8,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 28),

            // 2. 공부 기록 소개 제목
            const Text(
              '오늘의 공부를 차곡차곡',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
                letterSpacing: -0.7,
              ),
            ),

            const SizedBox(height: 14),

            // 3. 공부 기록 소개 문구
            const Text(
              '스마트 학습 좌석에서 측정한 공부 시간을 모아,\n나의 노력을 기록해요.',
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
