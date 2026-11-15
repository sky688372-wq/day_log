import 'dart:math' as math;

import 'package:day_log/core/models/statistics_model.dart';
import 'package:day_log/core/utils/time_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:day_log/core/models/daily_statistics_model.dart';
import 'package:table_calendar/table_calendar.dart';

import 'statistics_widgets.dart';
import 'study_session_detail_screen.dart';

class DailyStatisticsTab extends StatelessWidget {
  const DailyStatisticsTab({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.onMonthChanged,
    required this.selectedDay,
    required this.focusedDay,
    required this.firstDay,
    required this.today,
    required this.weekStart,
    required this.monthRecords,
    required this.weekly,
    required this.daily,
    required this.isMonthLoading,
    required this.isWeeklyLoading,
    required this.isDailyLoading,
    required this.onSelectDay,
    required this.onPageChanged,
    required this.onCalendarCreated,
    required this.onRetryMonth,
    required this.onRetryWeek,
    required this.onRetryDay,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onMonthChanged;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final DateTime firstDay;
  final DateTime today;
  final DateTime weekStart;
  final MonthlyStatisticsModel? monthRecords;
  final WeeklyStatisticsModel? weekly;
  final DailyStatisticsModel? daily;
  final bool isMonthLoading;
  final bool isWeeklyLoading;
  final bool isDailyLoading;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<PageController> onCalendarCreated;
  final VoidCallback onRetryMonth;
  final VoidCallback onRetryWeek;
  final VoidCallback onRetryDay;

  @override
  Widget build(BuildContext context) {
    final records = daily;
    final week = weekly;
    final start = weekStart;
    final end = start.add(const Duration(days: 6));

    // 응답의 날짜를 기준으로 월요일부터 7일을 대응
    final totals = {
      for (final day in (week?.days ?? <StatisticsDayModel>[]))
        day.date: day.totalStudySeconds,
    };

    final days = List.generate(
      7,
          (index) => weekStart.add(Duration(days: index)),
    );

    final minutes = days
        .map((day) => (totals[statisticsDateText(day)] ?? 0) / 60.0)
        .toList();

    final highest = minutes.fold<double>(
      0,
          (previous, value) => math.max(previous, value),
    );

    final maxY = math.max(1.0, highest * 1.2);

    final recordDates = {
      for (final day in monthRecords?.days ?? <StatisticsDayModel>[])
        if ((day.sessionCount ?? 0) > 0) day.date,
    };

    return statisticsList(
      context: context,
      onRefresh: onRefresh,
      controller: scrollController,
      children: [
        statisticsMonthSelector(focusedDay, onMonthChanged),
        const SizedBox(height: 12),
        statisticsPanel(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TableCalendar<String>(
                firstDay: firstDay,
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: focusedDay,
                currentDay: today,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                availableGestures: AvailableGestures.horizontalSwipe,
                selectedDayPredicate: (day) {
                  return isSameDay(day, selectedDay);
                },
                eventLoader: (day) {
                  return recordDates.contains(statisticsDateText(day))
                      ? ['record']
                      : <String>[];
                },
                onDaySelected: (selectedDay, _) {
                  onSelectDay(selectedDay);
                },
                // 화살표로 월을 바꿀 때 진행 중인 페이지 이동과 애니메이션이 겹치지 않게 함
                pageAnimationEnabled: false,
                onCalendarCreated: onCalendarCreated,
                onPageChanged: onPageChanged,
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
              if (isMonthLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('달력의 기록 표시를 불러오는 중이에요.'),
                )
              else if (monthRecords == null)
                statisticsFailure(onRetryMonth)
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
          '${selectedDay.month}월 ${selectedDay.day}일 '
              '${_weekdays[selectedDay.weekday - 1]}요일',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (isDailyLoading)
          statisticsLoading()
        else if (records == null)
          statisticsFailure(onRetryDay)
        else if (records.sessions.isEmpty)
            statisticsPanel(
              child: const Text(
                '이날 등록한 학습 기록이 없어요.',
                style: TextStyle(color: AppColor.textSecondary),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  TimeFormatter.toHms(records.totalStudySeconds),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '학습 기록 ${records.sessionCount}개',
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
                      for (final (index, session)
                      in records.sessions.indexed) ...[
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
                                    TimeFormatter.toHms(
                                      session.totalStudySeconds,
                                    ),
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
            ),
        const SizedBox(height: 20),
        statisticsPanel(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statisticsHeading(Icons.bar_chart_rounded, '주별 학습 시간'),
              const SizedBox(height: 8),
              Column(
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
                  if (isWeeklyLoading)
                    statisticsLoading()
                  else if (week == null)
                    statisticsFailure(onRetryWeek)
                  else
                    Column(
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
                          TimeFormatter.toHms(week.totalStudySeconds),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColor.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '단위: 분',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
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
                                        value.toStringAsFixed(
                                          value < 1 ? 1 : 0,
                                        ),
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

                                      final selected = isSameDay(
                                        days[index],
                                        selectedDay,
                                      );
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
                                      color: isSameDay(days[index], selectedDay)
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
                        statisticsHeading(Icons.view_list_rounded, '요일별 학습 기록'),
                        const SizedBox(height: 10),
                        for (var index = 0; index < days.length; index++)
                          _weeklyDayRow(
                            day: days[index],
                            seconds:
                            totals[statisticsDateText(days[index])] ?? 0,
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  String _timeText(DateTime value) {
    final kst = value.toUtc().add(const Duration(hours: 9));

    return '${kst.month}/${kst.day} '
        '${kst.hour.toString().padLeft(2, '0')}:'
        '${kst.minute.toString().padLeft(2, '0')}';
  }

  Widget _weeklyDayRow({required DateTime day, required int seconds}) {
    final selected = isSameDay(day, selectedDay);

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
}
