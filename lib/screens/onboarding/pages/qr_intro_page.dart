import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class QrIntroPage extends StatelessWidget {
  const QrIntroPage({super.key});

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
            // 1. QR 기록 저장 소개 이미지
            //todo Storyset 일러스트 출처는 앱 출처 안내에 표기하기
            Image.asset(
              'assets/images/QR Code-rafiki.png',
              height: screenSize.height * 0.35,
              width: screenSize.width * 0.8,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 28),

            // 2. QR 기록 저장 소개 제목
            const Text(
              '공부가 끝나면,\nQR로 간편하게',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
                letterSpacing: -0.7,
              ),
            ),

            const SizedBox(height: 14),

            // 3. QR 기록 저장 소개 문구
            const Text(
              '좌석 화면의 QR을 스캔하면,\n오늘의 공부 기록이 내 계정에 저장돼요.',
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
