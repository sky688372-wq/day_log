import 'package:day_log/core/models/daily_statistics_model.dart';
import 'package:day_log/core/models/login_response_model.dart';
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

  // 조회 실패 여부 (실패를 0분으로 보여주지 않기 위해 따로 관리)
  bool _isFailed = false;

  // 오늘 학습 기록
  DailyStatisticsModel? _today;

  @override
  void initState() {
    super.initState();
    print("화면 다시 생성됨");
    _loadToday();
  }

  // 오늘 학습 기록 불러오기
  Future<void> _loadToday() async {
    // 중복 요청 방지
    if (_isLoading && _today != null) return;

    final token = context.read<UserInfoProvider>().loginResponse?.token;

    setState(() {
      _isLoading = true;
      _isFailed = false;
    });

    // 토큰이 없으면 요청하지 않고 실패로 처리
    if (token == null || token.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _isFailed = true;
      });
      return;
    }

    final result = await ApiService.tryGetDailyStatistics(
      token: token,
      date: DateTime.now(),
    );

    // 비동기 작업 후 화면이 남아 있는지 확인
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isFailed = result == null;
      _today = result;
    });
  }

  // 당겨서 새로고침: 오늘 날짜 일별 통계만 다시 조회
  // 카드 안의 로딩 표시 대신 새로고침 인디케이터만 보여주기 위해 _isLoading은 바꾸지 않음
  Future<void> _refreshToday() async {
    // 처음 조회 중이면 중복 요청 방지
    if (_isLoading) return;

    final token = context.read<UserInfoProvider>().loginResponse?.token;

    // 토큰이 없으면 요청하지 않고 실패로 처리
    if (token == null || token.trim().isEmpty) {
      setState(() {
        _isFailed = true;
      });
      return;
    }

    final result = await ApiService.tryGetDailyStatistics(
      token: token,
      date: DateTime.now(),
    );

    // 비동기 작업 후 화면이 남아 있는지 확인
    if (!mounted) return;

    setState(() {
      _isFailed = result == null;
      _today = result;
    });
  }

  @override
  Widget build(BuildContext context) {

    // 사용자 정보
    final LoginResponseModel? userData = context
        .watch<UserInfoProvider>()
        .loginResponse;

    // 이름이 없을 때 null이 화면에 나오지 않도록 처리
    final String? name = userData?.name;
    final bool hasName = name != null && name.trim().isNotEmpty;

    // 오늘 날짜와 요일 (예: 11월 7일 토요일)
    const List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final DateTime now = DateTime.now();
    final String todayText =
        '${now.month}월 ${now.day}일 ${weekdays[now.weekday - 1]}요일';

    return Scaffold(
      backgroundColor: AppColor.background,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshToday,
          color: AppColor.primary,
          backgroundColor: AppColor.surfaceCard,
          child: SingleChildScrollView(
            // 내용이 짧아도 당길 수 있도록 설정
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // 1. 상단 날짜와 인사
                  Text(
                    todayText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasName ? '안녕하세요 ${name.trim()}님!' : '안녕하세요!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '오늘도 나만의 공부 흐름을 만들어봐요.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: AppColor.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. 오늘 학습 시간 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카드 제목과 시계 아이콘
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '오늘의 학습 시간',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor.onPrimary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.onPrimary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.schedule_rounded,
                                size: 22,
                                color: AppColor.onPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 조회 중
                        if (_isLoading) ...[
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColor.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '기록을 불러오고 있어요.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColor.onPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                        ]
                        // 조회 실패 (0분으로 표시하지 않고 다시 시도 제공)
                        else if (_isFailed) ...[
                          const Text(
                            '기록을 불러오지 못했어요.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColor.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '연결 상태를 확인하고 다시 시도해주세요.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColor.onPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _loadToday,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColor.onPrimary,
                              backgroundColor: AppColor.onPrimary.withValues(
                                alpha: 0.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text(
                              '다시 시도',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ]
                        // 정상 조회 (기록이 없으면 0분으로 표시)
                        else ...[
                            Text(
                              TimeFormatter.toHm(_today?.totalStudySeconds ?? 0),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: AppColor.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (_today?.sessionCount ?? 0) == 0
                                  ? '오늘 등록한 기록이 아직 없어요.'
                                  : '오늘 등록한 공부 기록을 모았어요.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: AppColor.onPrimary.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. 응원 메시지 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceTint,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColor.primaryContainer),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '조금씩 쌓인 시간이\n나만의 실력이 되어가요.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          'assets/images/home_cheer_sprout.png',
                          width: 110,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. QR 기록 등록 안내 카드
                  // todo QR 스캔 화면이 만들어지면 카드를 눌러 이동하도록 연결
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColor.outline),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/QR Code-rafiki.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '공부를 마쳤나요?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '아래 QR 스캔 버튼으로 기록을 남겨보세요.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}