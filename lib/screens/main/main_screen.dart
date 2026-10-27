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
  int _currnetIndex = 0;

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
      body: IndexedStack(
        index: _currnetIndex,
        children: [
          // todo각 탭에 해당하는 화면 넣기
        ],
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
                          child: Row(
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 2. 独立した円形バーコードボタン
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
