import 'dart:math' as math;

import 'package:day_log/core/models/statistics_model.dart';
import 'package:day_log/core/utils/time_formatter.dart';
import 'package:day_log/screens/main/tab/statistics/statistics_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';


class MonthlyStatisticsTab extends StatelessWidget {
  const MonthlyStatisticsTab({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.onMonthChanged,
    required this.month,
    required this.monthly,
    required this.isLoading,
    required this.onRetry,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onMonthChanged;
  final DateTime month;
  final MonthlyStatisticsModel? monthly;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final summary = monthly;
    final dayCount = DateTime.utc(month.year, month.month + 1, 0).day;
    final totals = {
      for (final day in monthly?.days ?? <StatisticsDayModel>[])
        day.date: day.totalStudySeconds,
    };
    final minutes = List<double>.generate(dayCount, (index) {
      final date = DateTime.utc(month.year, month.month, index + 1);
      return (totals[statisticsDateText(date)] ?? 0) / 60;
    });
    final highest = minutes.fold<double>(
      0,
          (max, value) => math.max(max, value),
    );
    final interval = math.max(1.0, (highest / 4).ceilToDouble());
    return statisticsList(
      context: context,
      onRefresh: onRefresh,
      controller: scrollController,
      children: [
        statisticsMonthSelector(month, onMonthChanged),
        const SizedBox(height: 12),
        if (isLoading)
          statisticsLoading()
        else if (summary == null)
          statisticsFailure(onRetry)
        else
          statisticsPanel(
            color: AppColor.surfaceTint,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                statisticsHeading(Icons.schedule_rounded, '월간 학습 시간'),
                const SizedBox(height: 8),
                Text(
                  TimeFormatter.toHms(summary.totalStudySeconds),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      '학습일 ${summary.studyDayCount}일',
                      style: const TextStyle(
                        color: AppColor.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (summary.days.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '이 달에 등록된 기록이 없어요.',
                    style: TextStyle(color: AppColor.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        statisticsPanel(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statisticsHeading(Icons.bar_chart_rounded, '날짜별 학습 시간'),
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
                            if (day != 1 &&
                                day != 8 &&
                                day != 15 &&
                                day != 22 &&
                                day != dayCount) {
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
        ),
      ],
    );
  }
}
