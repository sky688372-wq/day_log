import 'dart:ui';

import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/screens/main/tab/home/home_screen.dart';
import 'package:day_log/screens/main/tab/my/my_screen.dart';
import 'package:day_log/screens/main/tab/statistics/statistics_screen.dart';
import 'package:day_log/screens/qr/study_result_scan_screen.dart';
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
  static const double _tabBarBlur = 16.0;
  static const double _tabBarOpacity = 0.7;
  static const double _qrButtonBlur = 16.0;
  static const double _qrButtonOpacity = 0.7;

  int _selectedIndex = 0;
  int _recordsRevision = 0;

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

    // 각 폰마다 바텀 네비게이터 바가 시스템 자체의 바텀 네비게이터바에 바로 붙어 있지 않도록 하기 위함
    final systemBottom = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      // 바와 QR 버튼 주위로 본문이 비치도록 아래까지 확장
      extendBody: true,
      backgroundColor: AppColor.background,

      // 탭을 옮겨도 각 화면의 상태가 유지되도록 IndexedStack 사용
      // 탭을 추가하면 _labels, icons, selectedIcons, children 개수를 함께 맞춰야 함
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(key: ValueKey('home-$_recordsRevision')),
          StatisticsScreen(key: ValueKey('statistics-$_recordsRevision')),
          const MyScreen(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        // 시스템 하단 영역 위에 추가 간격 확보
        minimum: EdgeInsets.only(bottom: systemBottom + 12),
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
                        color: AppColor.textPrimary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        spreadRadius: -4,
                        offset: const Offset(0, 4),
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _tabBarBlur,
                        sigmaY: _tabBarBlur,
                      ),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: AppColor.surfaceCard.withValues(
                            alpha: _tabBarOpacity,
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
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.textPrimary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: -4,
                      offset: const Offset(0, 4),
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _qrButtonBlur,
                      sigmaY: _qrButtonBlur,
                    ),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.surfaceCard.withValues(
                          alpha: _qrButtonOpacity,
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
                        onPressed: () async {
                          final saved = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => const StudyResultScanScreen(),
                            ),
                          );
                          if (saved == true && mounted) {
                            setState(() => _recordsRevision++);
                          }
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
