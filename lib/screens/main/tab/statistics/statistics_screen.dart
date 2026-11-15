import 'dart:math' as math;

import 'package:day_log/core/models/daily_statistics_model.dart';
import 'package:day_log/core/models/statistics_model.dart';
import 'package:day_log/core/providers/user_info_provider.dart';
import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/core/utils/time_formatter.dart';
import 'package:day_log/screens/main/tab/statistics/study_session_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
  static final _calendarFirstDay = DateTime.utc(2000, 1, 1);// 캘린더의 시작 날짜
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

  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

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

  String _dateText(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
      DateTime.utc(_calendarFocusedDay.year, _calendarFocusedDay.month + amount),
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

  // 8. 세션 시각을 KST로 표시
  String _timeText(DateTime value) {
    final kst = value.toUtc().add(const Duration(hours: 9));

    return '${kst.month}/${kst.day} '
        '${kst.hour.toString().padLeft(2, '0')}:'
        '${kst.minute.toString().padLeft(2, '0')}';
  }

  // 9. 공통 로딩 표시
  Widget _loading() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator(color: AppColor.primary)),
    );
  }

  // 10. 조회 실패 표시
  Widget _failure(VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text(
            '기록을 불러오지 못했어요.\n서버 연결과 로그인 상태를 확인해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textSecondary),
          ),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }

  Widget _panel({
    required Widget child,
    Color color = AppColor.surfaceCard,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColor.outline),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _sectionHeading(IconData icon, String title) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 19, color: AppColor.primaryDark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // 11. 월 선택
  void _changeMonth(int amount, {required bool overview}) {
    if (!overview) {
      _moveMonth(amount);
      return;
    }

    setState(() {
      _overviewMonth = DateTime.utc(
        _overviewMonth.year,
        _overviewMonth.month + amount,
      );
    });
    _loadOverviewMonthly();
  }

  Widget _monthSelector({bool overview = false}) {
    final month = overview ? _overviewMonth : _calendarFocusedDay;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: '이전 달',
          onPressed: month.year == 2000 && month.month == 1
              ? null
              : () => _changeMonth(-1, overview: overview),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            '${month.year}년 ${month.month}월',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
        ),
        IconButton(
          tooltip: '다음 달',
          onPressed: month.year == 2100 && month.month == 12
              ? null
              : () => _changeMonth(1, overview: overview),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  // 12. 월별 요약
  Widget _monthlySummary() {
    if (_isOverviewMonthlyLoading) return _loading();
    if (_overviewMonthly == null) return _failure(_loadOverviewMonthly);

    final monthly = _overviewMonthly!;

    return _panel(
      color: AppColor.surfaceTint,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(Icons.schedule_rounded, '월간 학습 시간'),
          const SizedBox(height: 8),
          Text(
            TimeFormatter.toHms(monthly.totalStudySeconds),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColor.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColor.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                '학습일 ${monthly.studyDayCount}일',
                style: const TextStyle(
                  color: AppColor.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (monthly.days.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              '이 달에 등록된 기록이 없어요.',
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _monthlyChart() {
    final month = _overviewMonth;
    final dayCount = DateTime.utc(month.year, month.month + 1, 0).day;
    final totals = {
      for (final day in _overviewMonthly?.days ?? <StatisticsDayModel>[])
        day.date: day.totalStudySeconds,
    };
    final minutes = List<double>.generate(dayCount, (index) {
      final date = DateTime.utc(month.year, month.month, index + 1);
      return (totals[_dateText(date)] ?? 0) / 60;
    });
    final highest = minutes.fold<double>(0, (max, value) => math.max(max, value));
    final interval = math.max(1.0, (highest / 4).ceilToDouble());

    return _panel(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(Icons.bar_chart_rounded, '날짜별 학습 시간'),
          const SizedBox(height: 8),
          const Text(
            '단위: 분',
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: interval * 4,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: highest > 0),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        if (day != 1 && day != 8 && day != 15 &&
                            day != 22 && day != dayCount) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '$day일',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  dayCount,
                      (index) => BarChartGroupData(
                    x: index + 1,
                    barRods: [
                      BarChartRodData(
                        toY: minutes[index],
                        width: 4,
                        color: AppColor.primaryDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 13. 주별 학습 시간 그래프
  Widget _weeklyChart() {
    final start = _weekStart;
    final end = start.add(const Duration(days: 6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${start.year}.${start.month}.${start.day}'
                ' ~ ${end.year}.${end.month}.${end.day}',
            style: const TextStyle(color: AppColor.textSecondary),
          ),
        ),
        if (_isWeeklyLoading)
          _loading()
        else if (_weekly == null)
          _failure(_loadWeekly)
        else
          _weeklyChartBody(_weekly!),
      ],
    );
  }

  Widget _weeklyChartBody(WeeklyStatisticsModel weekly) {
    // 응답의 날짜를 기준으로 월요일부터 7일을 대응
    final totals = {
      for (final day in weekly.days) day.date: day.totalStudySeconds,
    };

    final days = List.generate(
      7,
          (index) => _weekStart.add(Duration(days: index)),
    );

    final minutes = days
        .map((day) => (totals[_dateText(day)] ?? 0) / 60.0)
        .toList();

    final highest = minutes.fold<double>(
      0,
          (previous, value) => math.max(previous, value),
    );

    final maxY = math.max(1.0, highest * 1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주간 합계',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TimeFormatter.toHms(weekly.totalStudySeconds),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColor.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '단위: 분',
          style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(value < 1 ? 1 : 0),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= days.length) {
                        return const SizedBox.shrink();
                      }

                      final selected = isSameDay(days[index], _selectedDay);
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${_weekdays[index]}\n'
                              '${days[index].month}/${days[index].day}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? AppColor.primaryDark
                                : AppColor.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(
                7,
                    (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: minutes[index],
                      width: 18,
                      color: isSameDay(days[index], _selectedDay)
                          ? AppColor.primaryDark
                          : AppColor.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 날짜별 학습 시간을 그래프 아래에서 확인
        _sectionHeading(Icons.view_list_rounded, '요일별 학습 기록'),
        const SizedBox(height: 10),
        for (var index = 0; index < days.length; index++)
          _weeklyDayRow(
            day: days[index],
            seconds: totals[_dateText(days[index])] ?? 0,
          ),
      ],
    );
  }

  Widget _weeklyDayRow({required DateTime day, required int seconds}) {
    final selected = isSameDay(day, _selectedDay);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColor.surfaceTint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: selected
                  ? AppColor.primaryContainer
                  : AppColor.surfaceSunken,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_weekdays[day.weekday - 1]}요일',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? AppColor.primaryDark : AppColor.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${day.month}월 ${day.day}일',
              style: const TextStyle(color: AppColor.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              TimeFormatter.toHms(seconds),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: seconds > 0
                    ? AppColor.primaryDark
                    : AppColor.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _refreshableList({
    required ScrollController controller,
    required List<Widget> children,
  }) {
    return RefreshIndicator(
      color: AppColor.primaryDark,
      backgroundColor: AppColor.surfaceCard,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () => _reload(keepContent: true),
      child: ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        children: children,
      ),
    );
  }

  // 14. 월별 통계 탭
  Widget _overviewTab() {
    return _refreshableList(
      controller: _monthlyScroll,
      children: [
        _monthSelector(overview: true),
        const SizedBox(height: 12),
        _monthlySummary(),
        const SizedBox(height: 16),
        _monthlyChart(),
      ],
    );
  }

  // 15. 날짜별 기록 탭
  Widget _dailyTab() {
    final recordDates = {
      for (final day in _monthly?.days ?? <StatisticsDayModel>[])
        if ((day.sessionCount ?? 0) > 0) day.date,
    };

    return _refreshableList(
      controller: _dailyScroll,
      children: [
        _monthSelector(),
        const SizedBox(height: 12),
        _panel(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TableCalendar<String>(
                firstDay: _calendarFirstDay,
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _calendarFocusedDay,
                currentDay: _kstToday(),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                availableGestures: AvailableGestures.horizontalSwipe,
                selectedDayPredicate: (day) {
                  return isSameDay(day, _selectedDay);
                },
                eventLoader: (day) {
                  return recordDates.contains(_dateText(day))
                      ? ['record']
                      : <String>[];
                },
                onDaySelected: (selectedDay, _) {
                  _selectDay(selectedDay);
                },
                // 화살표로 월을 바꿀 때 진행 중인 페이지 이동과 애니메이션이 겹치지 않게 함
                pageAnimationEnabled: false,
                onCalendarCreated: (controller) {
                  _calendarController = controller;
                },
                onPageChanged: _onCalendarPageChanged,
                calendarBuilders: CalendarBuilders<String>(
                  dowBuilder: (context, day) {
                    return Center(
                      child: Text(
                        _weekdays[day.weekday - 1],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: day.weekday == DateTime.sunday
                              ? AppColor.error
                              : AppColor.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(
                    color: AppColor.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColor.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: AppColor.textPrimary),
                  markerDecoration: BoxDecoration(
                    color: AppColor.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (_isMonthlyLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('달력의 기록 표시를 불러오는 중이에요.'),
                )
              else if (_monthly == null)
                _failure(_loadMonthly)
              else
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 7, color: AppColor.tertiary),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '학습 기록이 있는 날',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${_selectedDay.month}월 ${_selectedDay.day}일 '
              '${_weekdays[_selectedDay.weekday - 1]}요일',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _dailyRecords(),
        const SizedBox(height: 20),
        _panel(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading(Icons.bar_chart_rounded, '주별 학습 시간'),
              const SizedBox(height: 8),
              _weeklyChart(),
            ],
          ),
        ),
      ],
    );
  }

  DateTime _kstToday() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    return DateTime.utc(now.year, now.month, now.day);
  }

  // 16. 선택한 날짜의 기록
  Widget _dailyRecords() {
    if (_isDailyLoading) return _loading();
    if (_daily == null) return _failure(_loadDaily);

    final daily = _daily!;

    if (daily.sessions.isEmpty) {
      return _panel(
        child: const Text(
          '이날 등록한 학습 기록이 없어요.',
          style: TextStyle(color: AppColor.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TimeFormatter.toHms(daily.totalStudySeconds),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColor.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '학습 기록 ${daily.sessionCount}개',
          style: const TextStyle(color: AppColor.textSecondary),
        ),
        const SizedBox(height: 16),
        Material(
          color: AppColor.surfaceCard,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColor.outline),
          ),
          child: Column(
            children: [
              for (final (index, session) in daily.sessions.indexed) ...[
                if (index > 0)
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColor.outline,
                  ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudySessionDetailScreen(session: session),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_timeText(session.startTime)}'
                                    ' ~ ${_timeText(session.endTime)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '자세 경고 ${session.postureWarningCount}회'
                                    ' · 졸음 ${session.drowsinessCount}회',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            TimeFormatter.toHms(session.totalStudySeconds),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColor.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColor.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
                  splashBorderRadius: const BorderRadius.all(Radius.circular(12)),
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
              children: [_overviewTab(), _dailyTab()],
            ),
          ),
        ],
      ),
    );
  }
}
