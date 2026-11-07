import 'package:day_log/core/models/daily_statistics_model.dart';
import 'package:day_log/core/providers/user_info_provider.dart';
import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/core/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 오늘 학습 기록 조회 중 여부
  bool _isLoading = true;

  // 중복 요청 방지
  bool _isRequesting = false;

  // 조회 실패 여부
  bool _isFailed = false;

  // 오늘 학습 기록
  DailyStatisticsModel? _today;

  // 현재 표시 중인 기록의 기준 날짜
  late DateTime _todayDate;

  @override
  void initState() {
    super.initState();

    _todayDate = _kstToday();
    _loadToday();
  }

  // 1. 한국 표준시 기준 오늘 날짜
  DateTime _kstToday() {
    final now = DateTime.now().toUtc().add(
      const Duration(hours: 9),
    );

    // 서버에 전달할 연·월·일 값으로 사용
    return DateTime.utc(now.year, now.month, now.day);
  }

  // 2. 오늘 학습 기록 불러오기
  Future<void> _loadToday({
    bool showLoading = true,
  }) async {
    if (_isRequesting) return;

    final token = context.read<UserInfoProvider>().loginResponse?.token;
    final date = _kstToday();

    setState(() {
      _isRequesting = true;

      if (showLoading) {
        _isLoading = true;
        _isFailed = false;
      }
    });

    DailyStatisticsModel? result;

    try {
      // 토큰이 없으면 서버 요청 없이 실패로 처리
      if (token != null && token.trim().isNotEmpty) {
        result = await ApiService.tryGetDailyStatistics(
          token: token,
          date: date,
        );
      }
    } catch (e) {
      // 예상하지 못한 오류도 조회 실패로 처리
      result = null;
    }

    if (!mounted) return;

    setState(() {
      _today = result;
      _todayDate = date;
      _isFailed = result == null;
      _isLoading = false;
      _isRequesting = false;
    });
  }

  // 3. 당겨서 새로고침
  // 기존 내용을 유지하면서 상단 새로고침 표시만 사용
  Future<void> _refreshToday() async {
    await _loadToday(showLoading: false);
  }

  // 4. 오늘의 학습 시간 카드
  Widget _studyTimeCard() {
    final today = _today;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary,
            AppColor.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 카드 제목
          Row(
            children: [
              const Expanded(
                child: Text(
                  '오늘의 학습 시간',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColor.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.onPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 24,
                  color: AppColor.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. 조회 중
          if (_isLoading) ...[
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColor.onPrimary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '오늘의 기록을 불러오고 있어요.',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.onPrimary.withValues(alpha: 0.88),
              ),
            ),
          ]

          // 3. 조회 실패
          else if (_isFailed || today == null) ...[
            const Text(
              '기록을 불러오지\n못했어요.',
              style: TextStyle(
                fontSize: 26,
                height: 1.35,
                fontWeight: FontWeight.bold,
                color: AppColor.onPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '연결 상태를 확인하고 다시 시도해주세요.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColor.onPrimary.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _isRequesting
                  ? null
                  : () {
                _loadToday();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColor.onPrimary,
                backgroundColor:
                AppColor.onPrimary.withValues(alpha: 0.16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 19,
              ),
              label: const Text(
                '다시 시도',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]

          // 4. 정상 조회
          else ...[
              Text(
                TimeFormatter.toHm(today.totalStudySeconds),
                style: const TextStyle(
                  fontSize: 40,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppColor.onPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                today.sessionCount == 0
                    ? '오늘 날짜로 등록된 기록이 아직 없어요.'
                    : '오늘 날짜로 등록된 공부 시간을 모았어요.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColor.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),
              Divider(
                height: 1,
                color: AppColor.onPrimary.withValues(alpha: 0.24),
              ),
              const SizedBox(height: 18),

              // 실시간 측정값이 아닌 등록된 기록의 개수
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: AppColor.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '등록된 학습 기록 ${today.sessionCount}개',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }

  // 5. 응원 메시지 카드
  Widget _cheerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.tertiaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 응원',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textSecondary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '조금씩 쌓인 시간이\n나만의 실력이 되어가요.',
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/home_cheer_sprout.png',
            width: 88,
            height: 104,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ],
      ),
    );
  }

  // 6. QR 기록 등록 안내
  Widget _qrGuideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColor.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 24,
                  color: AppColor.primaryDark,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '공부의 마무리는 기록으로',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '좌석에서의 공부를\n나만의 학습 기록으로 남겨보세요.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            color: AppColor.outline,
          ),
          const SizedBox(height: 14),

          // TODO: QR 스캔·등록 기능 연결 후 아래 안내 문구 변경
          const Text(
            'QR 기록 등록 기능을 준비하고 있어요.',
            style: TextStyle(
              fontSize: 12,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserInfoProvider>().loginResponse;

    final name = userData?.name?.trim();
    final hasName = name != null && name.isNotEmpty;

    const weekdays = [
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
    ];

    final todayText =
        '${_todayDate.month}월 ${_todayDate.day}일 '
        '${weekdays[_todayDate.weekday - 1]}요일';

    return ColoredBox(
      color: AppColor.background,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshToday,
          color: AppColor.primary,
          backgroundColor: AppColor.surfaceCard,
          child: SingleChildScrollView(
            // 내용이 짧아도 당겨서 새로고침 가능
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 화면 제목
                  const Text(
                    '홈',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. 상단 날짜
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceSunken,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      todayText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. 사용자 인사
                  Text(
                    hasName ? '$name님, 반가워요!' : '반가워요!',
                    style: const TextStyle(
                      fontSize: 27,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '오늘도 나만의 공부 흐름을 만들어봐요.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // 4. 오늘의 학습 시간
                  _studyTimeCard(),
                  const SizedBox(height: 26),

                  // 5. 응원 영역
                  const Text(
                    '꾸준히 쌓아가는 하루',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _cheerCard(),
                  const SizedBox(height: 16),

                  // 6. QR 안내
                  _qrGuideCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}