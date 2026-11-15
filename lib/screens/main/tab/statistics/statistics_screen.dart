import 'package:day_log/core/models/daily_statistics_model.dart';
import 'package:day_log/core/models/statistics_model.dart';
import 'package:day_log/core/providers/user_info_provider.dart';
import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'daily_statistics_tab.dart';
import 'monthly_statistics_tab.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _monthlyScroll = ScrollController(keepScrollOffset: false);
  final _dailyScroll = ScrollController(keepScrollOffset: false);
  int _lastTabIndex = 0;
  // 선택한 날짜
  late DateTime _selectedDay;
  late DateTime _calendarFocusedDay;
  PageController? _calendarController;
  static final _calendarFirstDay = DateTime.utc(2000, 1, 1); // 캘린더의 시작 날짜
  late DateTime _overviewMonth;

  // 조회 결과
  MonthlyStatisticsModel? _monthly;
  MonthlyStatisticsModel? _overviewMonthly;
  bool _isOverviewMonthlyLoading = true;
  int _overviewMonthlyRequestId = 0;
  WeeklyStatisticsModel? _weekly;
  DailyStatisticsModel? _daily;

  // 조회 상태
  bool _isMonthlyLoading = true;
  bool _isWeeklyLoading = true;
  bool _isDailyLoading = true;

  // 이전 요청이 늦게 도착해 최신 결과를 덮어쓰지 않도록 관리
  int _monthlyRequestId = 0;
  int _weeklyRequestId = 0;
  int _dailyRequestId = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);

    _selectedDay = _kstToday();
    _calendarFocusedDay = _selectedDay;
    _overviewMonth = DateTime.utc(_selectedDay.year, _selectedDay.month);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reload();
    });
  }

  void _handleTabChange() {
    final index = _tabs.index;
    if (index == _lastTabIndex) return;
    _lastTabIndex = index;
    final scroll = index == 0 ? _monthlyScroll : _dailyScroll;
    if (scroll.hasClients) {
      scroll.jumpTo(scroll.position.minScrollExtent);
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_handleTabChange);
    _tabs.dispose();
    _monthlyScroll.dispose();
    _dailyScroll.dispose();
    super.dispose();
  }

  // 1. 날짜 비교에 사용할 날짜값
  // 달력 날짜는 실제 시각이 아닌 연·월·일 값으로 관리
  DateTime _dateOnly(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  DateTime get _weekStart {
    return _selectedDay.subtract(
      Duration(days: _selectedDay.weekday - DateTime.monday),
    );
  }

  String? get _token {
    return context.read<UserInfoProvider>().loginResponse?.token;
  }

  // 2. 전체 새로고침
  Future<void> _reload({bool keepContent = false}) async {
    await Future.wait<void>([
      _loadOverviewMonthly(keepContent: keepContent),
      _loadMonthly(keepContent: keepContent),
      _loadWeekly(keepContent: keepContent),
      _loadDaily(keepContent: keepContent),
    ]);
  }

  // 3. 월별 조회
  Future<void> _loadMonthly({bool keepContent = false}) async {
    final requestId = ++_monthlyRequestId;
    final date = _calendarFocusedDay;
    final token = _token;

    if (!keepContent || _monthly == null) {
      setState(() {
        _isMonthlyLoading = true;
        _monthly = null;
      });
    }

    final result = token == null || token.trim().isEmpty
        ? null
        : await ApiService.tryGetMonthlyStatistics(token: token, month: date);

    if (!mounted || requestId != _monthlyRequestId) return;

    setState(() {
      _monthly = result;
      _isMonthlyLoading = false;
    });
  }

  Future<void> _loadOverviewMonthly({bool keepContent = false}) async {
    final month = _overviewMonth;
    final requestId = ++_overviewMonthlyRequestId;
    final token = _token;

    if (!keepContent || _overviewMonthly == null) {
      setState(() {
        _isOverviewMonthlyLoading = true;
        _overviewMonthly = null;
      });
    }

    final result = token == null || token.trim().isEmpty
        ? null
        : await ApiService.tryGetMonthlyStatistics(token: token, month: month);

    if (!mounted || requestId != _overviewMonthlyRequestId) return;

    setState(() {
      _overviewMonthly = result;
      _isOverviewMonthlyLoading = false;
    });
  }

  // 4. 주별 조회
  Future<void> _loadWeekly({bool keepContent = false}) async {
    final requestId = ++_weeklyRequestId;
    final start = _weekStart;
    final token = _token;

    if (!keepContent || _weekly == null) {
      setState(() {
        _isWeeklyLoading = true;
        _weekly = null;
      });
    }

    final result = token == null || token.trim().isEmpty
        ? null
        : await ApiService.tryGetWeeklyStatistics(
      token: token,
      startDate: start,
      endDate: start.add(const Duration(days: 6)),
    );

    if (!mounted || requestId != _weeklyRequestId) return;

    setState(() {
      _weekly = result;
      _isWeeklyLoading = false;
    });
  }

  // 5. 일별 조회
  Future<void> _loadDaily({bool keepContent = false}) async {
    final requestId = ++_dailyRequestId;
    final date = _selectedDay;
    final token = _token;

    if (!keepContent || _daily == null) {
      setState(() {
        _isDailyLoading = true;
        _daily = null;
      });
    }

    final result = token == null || token.trim().isEmpty
        ? null
        : await ApiService.tryGetDailyStatistics(token: token, date: date);

    if (!mounted || requestId != _dailyRequestId) return;

    setState(() {
      _daily = result;
      _isDailyLoading = false;
    });
  }

  // 6. 날짜 변경
  void _selectDay(DateTime value) {
    final next = _dateOnly(value);

    if (isSameDay(next, _selectedDay)) return;

    final previousWeek = _weekStart;

    setState(() {
      _selectedDay = next;
    });

    if (previousWeek != _weekStart) {
      _loadWeekly();
    }
    _loadDaily();
  }

  // 7. 월 이동
  void _moveMonth(int amount) {
    _focusCalendarMonth(
      DateTime.utc(
        _calendarFocusedDay.year,
        _calendarFocusedDay.month + amount,
      ),
    );
  }

  // 실제 페이지 번호로 표시 월을 계산해 이전 콜백의 날짜에 의존하지 않음
  void _onCalendarPageChanged(DateTime _) {
    final controller = _calendarController;
    if (controller == null || !controller.hasClients) return;
    final page = controller.page?.round();
    if (page == null) return;

    _focusCalendarMonth(
      DateTime.utc(_calendarFirstDay.year, _calendarFirstDay.month + page),
    );
  }

  // 달력의 표시 월과 기록 조회 날짜는 따로 유지
  void _focusCalendarMonth(DateTime day) {
    if (day.year == _calendarFocusedDay.year &&
        day.month == _calendarFocusedDay.month) {
      return;
    }

    setState(() {
      _calendarFocusedDay = _dateOnly(day);
    });
    _loadMonthly();
  }

  // 11. 월 선택
  void _changeOverviewMonth(int amount) {
    setState(() {
      _overviewMonth = DateTime.utc(
        _overviewMonth.year,
        _overviewMonth.month + amount,
      );
    });
    _loadOverviewMonthly();
  }

  DateTime _kstToday() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    return DateTime.utc(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '통계',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
                // IconButton(
                //   tooltip: '통계 새로고침',
                //   onPressed: _reload,
                //   icon: const Icon(Icons.refresh),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Material(
              color: AppColor.surfaceSunken,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabs,
                  splashBorderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ),
                  labelColor: AppColor.primaryDark,
                  unselectedLabelColor: AppColor.textSecondary,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: const BoxDecoration(
                    color: AppColor.primaryContainer,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  tabs: const [
                    Tab(text: '월별 통계'),
                    Tab(text: '날짜별 기록'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                MonthlyStatisticsTab(
                  scrollController: _monthlyScroll,
                  onRefresh: () => _reload(keepContent: true),
                  onMonthChanged: _changeOverviewMonth,
                  month: _overviewMonth,
                  monthly: _overviewMonthly,
                  isLoading: _isOverviewMonthlyLoading,
                  onRetry: _loadOverviewMonthly,
                ),
                DailyStatisticsTab(
                  scrollController: _dailyScroll,
                  onRefresh: () => _reload(keepContent: true),
                  onMonthChanged: _moveMonth,
                  selectedDay: _selectedDay,
                  focusedDay: _calendarFocusedDay,
                  today: _kstToday(),
                  firstDay: _calendarFirstDay,
                  weekStart: _weekStart,
                  monthRecords: _monthly,
                  weekly: _weekly,
                  daily: _daily,
                  isMonthLoading: _isMonthlyLoading,
                  isWeeklyLoading: _isWeeklyLoading,
                  isDailyLoading: _isDailyLoading,
                  onSelectDay: _selectDay,
                  onCalendarCreated: (controller) =>
                  _calendarController = controller,
                  onPageChanged: _onCalendarPageChanged,
                  onRetryMonth: _loadMonthly,
                  onRetryWeek: _loadWeekly,
                  onRetryDay: _loadDaily,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}