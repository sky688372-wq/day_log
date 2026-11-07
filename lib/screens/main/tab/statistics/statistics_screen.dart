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

class _StatisticsScreenState extends State<StatisticsScreen> {
  // 선택한 날짜
  late DateTime _selectedDay;

  // 조회 결과
  MonthlyStatisticsModel? _monthly;
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

  static const List<String> _weekdays = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  @override
  void initState() {
    super.initState();

    // 기기 시간대와 관계없이 KST의 오늘 날짜 사용
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    _selectedDay = DateTime.utc(now.year, now.month, now.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reload();
    });
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
  void _reload() {
    _loadMonthly();
    _loadWeekly();
    _loadDaily();
  }

  // 3. 월별 조회
  Future<void> _loadMonthly() async {
    final requestId = ++_monthlyRequestId;
    final date = _selectedDay;
    final token = _token;

    setState(() {
      _isMonthlyLoading = true;
      _monthly = null;
    });

    final result = token == null || token.trim().isEmpty
        ? null
        : await ApiService.tryGetMonthlyStatistics(
      token: token,
      month: date,
    );

    if (!mounted || requestId != _monthlyRequestId) return;

    setState(() {
      _monthly = result;
      _isMonthlyLoading = false;
    });
  }

  // 4. 주별 조회
  Future<void> _loadWeekly() async {
    final requestId = ++_weeklyRequestId;
    final start = _weekStart;
    final token = _token;

    setState(() {
      _isWeeklyLoading = true;
      _weekly = null;
    });

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
  Future<void> _loadDaily() async {
    final requestId = ++_dailyRequestId;
    final date = _selectedDay;
    final token = _token;

    setState(() {
      _isDailyLoading = true;
      _daily = null;
    });

    final result = token == null || token.trim().isEmpty
        ? null
        : await ApiService.tryGetDailyStatistics(
      token: token,
      date: date,
    );

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

    final previous = _selectedDay;
    final previousWeekStart = _weekStart;

    setState(() {
      _selectedDay = next;
    });

    if (previous.year != next.year || previous.month != next.month) {
      _loadMonthly();
    }

    if (!isSameDay(previousWeekStart, _weekStart)) {
      _loadWeekly();
    }

    _loadDaily();
  }

  // 7. 월 이동
  void _moveMonth(int amount) {
    _selectDay(
      DateTime.utc(
        _selectedDay.year,
        _selectedDay.month + amount,
        1,
      ),
    );
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
      child: Center(
        child: CircularProgressIndicator(
          color: AppColor.primary,
        ),
      ),
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
          TextButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  // 11. 월 선택
  Widget _monthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: '이전 달',
          onPressed: _selectedDay.year == 2000 && _selectedDay.month == 1
              ? null
              : () => _moveMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${_selectedDay.year}년 ${_selectedDay.month}월',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          tooltip: '다음 달',
          onPressed: _selectedDay.year == 2100 && _selectedDay.month == 12
              ? null
              : () => _moveMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  // 12. 월별 요약
  Widget _monthlySummary() {
    if (_isMonthlyLoading) return _loading();
    if (_monthly == null) return _failure(_loadMonthly);

    final monthly = _monthly!;

    return Card(
      color: AppColor.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이번 조회 월의 학습 시간'),
            const SizedBox(height: 8),
            Text(
              TimeFormatter.toHms(monthly.totalStudySeconds),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text('학습일 ${monthly.studyDayCount}일'),
            if (monthly.days.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '이 달에 등록된 기록이 없어요.',
                style: TextStyle(color: AppColor.textSecondary),
              ),
            ],
          ],
        ),
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
        Row(
          children: [
            IconButton(
              tooltip: '이전 주',
              onPressed: () {
                final next = _selectedDay.subtract(
                  const Duration(days: 7),
                );
                if (next.isBefore(DateTime.utc(2000))) return;
                _selectDay(next);
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${start.year}.${start.month}.${start.day}'
                    ' ~ ${end.year}.${end.month}.${end.day}',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: '다음 주',
              onPressed: () {
                final next = _selectedDay.add(
                  const Duration(days: 7),
                );
                if (next.isAfter(DateTime.utc(2100, 12, 31))) return;
                _selectDay(next);
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
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
        Text(
          '주 총 학습 시간: '
              '${TimeFormatter.toHms(weekly.totalStudySeconds)}',
        ),
        const SizedBox(height: 8),
        const Text(
          '세로축 단위: 분',
          style: TextStyle(color: AppColor.textSecondary),
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
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
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

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${_weekdays[index]}\n'
                              '${days[index].month}/${days[index].day}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10),
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

        // 짧은 기록도 정확한 시간으로 확인
        ...List.generate(
          7,
              (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              '${_weekdays[index]} '
                  '${days[index].month}/${days[index].day}  '
                  '${TimeFormatter.toHms(totals[_dateText(days[index])] ?? 0)}',
            ),
          ),
        ),
      ],
    );
  }

  // 14. 전체 통계 탭
  Widget _overviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _monthSelector(),
        _monthlySummary(),
        const SizedBox(height: 24),
        const Text(
          '주별 학습 시간',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _weeklyChart(),
      ],
    );
  }

  // 15. 날짜별 기록 탭
  Widget _dailyTab() {
    final recordDates = {
      for (final day in _monthly?.days ?? <StatisticsDayModel>[])
        if ((day.sessionCount ?? 0) > 0) day.date,
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _monthSelector(),
        TableCalendar<String>(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _selectedDay,
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
          onDaySelected: (selectedDay, focusedDay) {
            _selectDay(selectedDay);
          },
          onPageChanged: (focusedDay) {
            _selectDay(
              DateTime.utc(
                focusedDay.year,
                focusedDay.month,
                1,
              ),
            );
          },
          calendarBuilders: CalendarBuilders<String>(
            dowBuilder: (context, day) {
              return Center(
                child: Text(_weekdays[day.weekday - 1]),
              );
            },
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            selectedDecoration: BoxDecoration(
              color: AppColor.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColor.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: AppColor.textPrimary,
            ),
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
          const Text(
            '점이 있는 날짜는 등록된 학습 기록이 있는 날이에요.',
            style: TextStyle(
              fontSize: 12,
              color: AppColor.textSecondary,
            ),
          ),
        const SizedBox(height: 24),
        Text(
          '${_selectedDay.month}월 ${_selectedDay.day}일 기록',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _dailyRecords(),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '총 ${TimeFormatter.toHms(daily.totalStudySeconds)}'
              ' · 기록 ${daily.sessionCount}개',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (daily.sessions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              '이 날짜에 등록된 학습 기록이 없어요.\n'
                  '공부를 마쳤다면 QR로 기록을 등록해주세요.',
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
        ...daily.sessions.map(
              (session) => Card(
            color: AppColor.surfaceCard,
            child: ListTile(
              isThreeLine: true,
              title: Text(
                TimeFormatter.toHms(session.totalStudySeconds),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${_timeText(session.startTime)}'
                    ' ~ ${_timeText(session.endTime)}\n'
                    '자세 경고 ${session.postureWarningCount}회'
                    ' · 졸음 ${session.drowsinessCount}회',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudySessionDetailScreen(
                      session: session,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
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
                  IconButton(
                    tooltip: '통계 새로고침',
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            const TabBar(
              labelColor: AppColor.primary,
              unselectedLabelColor: AppColor.textSecondary,
              indicatorColor: AppColor.primary,
              tabs: [
                Tab(text: '전체 통계'),
                Tab(text: '날짜별 기록'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _overviewTab(),
                  _dailyTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}