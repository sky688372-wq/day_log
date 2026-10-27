import 'dart:ui';

import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //현재 선택한 탭
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    //플랫폼에 따라 아이콘만 변경
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final labels = ['홈', '통계', '마이'];

    final icons = [
      isIOS ? CupertinoIcons.house : Icons.home_outlined,
      CupertinoIcons.chart_bar, //선택 전: 테두리만 있는 막대
      isIOS ? CupertinoIcons.person : Icons.person_outline,
    ];

    final selectedIcons = [
      isIOS ? CupertinoIcons.house_fill : Icons.home,
      CupertinoIcons.chart_bar_fill, //선택 후: 채워진 막대
      isIOS ? CupertinoIcons.person_fill : Icons.person,
    ];

    return Scaffold(
      //본문이 네비게이션 바 뒤까지 보이도록 설정
      extendBody: true,
      backgroundColor: AppColor.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // 1. 홈·통계·마이 네비게이션 바
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.textPrimary.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      //블러는 약하게 적용
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),

                          //밝은 반투명 유리 배경
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColor.surfaceCard.withValues(alpha: 0.72),
                              AppColor.surfaceCard.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: AppColor.outline.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Stack(
                            children: [
                              //선택한 탭을 따라 움직이는 회색 캡슐
                              Positioned.fill(
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment(
                                    -1.0 +
                                        (2.0 *
                                            _selectedIndex /
                                            (labels.length - 1)),
                                    0,
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: 1 / labels.length,
                                    heightFactor: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(35),
                                        color: AppColor.textPrimary.withValues(
                                          alpha: 0.12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //탭 아이콘과 이름
                              Row(
                                children: List.generate(labels.length, (index) {
                                  final isSelected = _selectedIndex == index;

                                  return Expanded(
                                    child: Semantics(
                                      button: true,
                                      selected: isSelected,
                                      label: labels[index],
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _selectedIndex = index;
                                          });
                                        },
                                        child: SizedBox(
                                          height: double.infinity,
                                          child: ExcludeSemantics(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isSelected
                                                      ? selectedIcons[index]
                                                      : icons[index],
                                                  size: 26,
                                                  color: AppColor.textPrimary,
                                                ),

                                                const SizedBox(height: 3),

                                                Text(
                                                  labels[index],
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: AppColor.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 2. 독립된 원형 바코드 버튼
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.textPrimary.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColor.surfaceCard.withValues(alpha: 0.72),
                            AppColor.surfaceCard.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      foregroundDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.outline.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: IconButton(
                        tooltip: '공부 기록 스캔',
                        onPressed: () {
                          //todo QR 스캔 화면으로 이동
                        },
                        icon: const Icon(
                          CupertinoIcons.barcode,
                          size: 30,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
