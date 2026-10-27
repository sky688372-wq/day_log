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
  // 고정된 탭 이름
  static const List<String> _labels = ['홈', '통계', '마이'];

  // 현재 선택한 탭
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 플랫폼에 따라 아이콘만 변경
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final icons = <IconData>[
      isIOS ? CupertinoIcons.house : Icons.home_outlined,
      CupertinoIcons.chart_bar,
      isIOS ? CupertinoIcons.person : Icons.person_outline,
    ];

    final selectedIcons = <IconData>[
      isIOS ? CupertinoIcons.house_fill : Icons.home,
      CupertinoIcons.chart_bar_fill,
      isIOS ? CupertinoIcons.person_fill : Icons.person,
    ];

    return Scaffold(
      // 본문이 네비게이션 바 아래로 확장되지 않도록 설정
      extendBody: false,
      backgroundColor: AppColor.background,

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        // iOS 홈 인디케이터와 간격 확보
        minimum: const EdgeInsets.only(bottom: 20),
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
                        blurRadius: 14,
                        offset: const Offset(0, 2),
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      // 네비게이션 바에만 블러 적용
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
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
                            fit: StackFit.expand,
                            children: [
                              // 선택한 탭을 따라 움직이는 회색 캡슐
                              Positioned.fill(
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment(
                                    -1.0 +
                                        (2.0 *
                                            _selectedIndex /
                                            (_labels.length - 1)),
                                    0,
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: 1 / _labels.length,
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

                              // 탭 아이콘과 이름
                              Row(
                                children: List.generate(_labels.length, (
                                  index,
                                ) {
                                  final isSelected = _selectedIndex == index;

                                  return Expanded(
                                    child: Semantics(
                                      button: true,
                                      selected: isSelected,
                                      label: _labels[index],
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          // 이미 선택된 탭이면 생략
                                          if (_selectedIndex == index) {
                                            return;
                                          }

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
                                                  size: 24,
                                                  color: AppColor.textPrimary,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _labels[index],
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    height: 1.0,
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
              // 추가 블러 없이 기존 유리 배경과 그림자 유지
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.textPrimary.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 2),
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: ClipOval(
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
                        // TODO: QR 스캔 화면으로 이동
                      },
                      icon: const Icon(
                        CupertinoIcons.qrcode_viewfinder,
                        size: 30,
                        color: AppColor.textPrimary,
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
