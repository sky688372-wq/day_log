import 'package:day_log/core/models/study_session_model.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/core/utils/time_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StudySessionDetailScreen extends StatelessWidget {
  final StudySessionModel session;

  const StudySessionDetailScreen({super.key, required this.session});

  // 1. UTC 시각을 KST 표시값으로 변환
  // 변환한 값은 표시용이며 서버로 다시 전송하지 않음
  String _timeText(DateTime value) {
    final kst = value.toUtc().add(const Duration(hours: 9));

    return '${kst.month}/${kst.day} '
        '${kst.hour.toString().padLeft(2, '0')}:'
        '${kst.minute.toString().padLeft(2, '0')}:'
        '${kst.second.toString().padLeft(2, '0')}';
  }

  // 2. 세션 시작으로부터 경과한 초
  double _elapsedSeconds(DateTime value) {
    return value.difference(session.startTime).inMicroseconds /
        Duration.microsecondsPerSecond;
  }

  // 3. 감지 로그를 점으로 표시
  LineChartBarData _eventDots({
    required List<DetectionLogModel> logs,
    required String type,
    required double row,
    required Color color,
  }) {
    return LineChartBarData(
      spots: logs
          .where((log) => log.type == type)
          .map((log) => FlSpot(_elapsedSeconds(log.time), row))
          .toList(),

      // 점 사이에 선을 연결하지 않음
      barWidth: 0,
      color: color,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 1,
            strokeColor: AppColor.surfaceCard,
          );
        },
      ),
    );
  }

  // 4. 경고 발생 시점 그래프
  Widget _eventChart() {
    final durationSeconds =
        session.endTime.difference(session.startTime).inMicroseconds /
        Duration.microsecondsPerSecond;

    // 시작과 종료의 순서가 올바르지 않으면 그래프를 그리지 않음
    if (durationSeconds <= 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          '시작·종료 시각의 간격이 없어 그래프를 표시할 수 없어요.\n'
          '아래 목록에서 감지 시각을 확인해주세요.',
          style: TextStyle(color: AppColor.textSecondary),
        ),
      );
    }

    final validLogs = session.detectionLogs.where((log) {
      return !log.time.isBefore(session.startTime) &&
          !log.time.isAfter(session.endTime);
    }).toList();

    final outsideCount = session.detectionLogs.length - validLogs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '가로축은 세션 시작 이후의 경과 시간이에요.\n'
          '각 점은 경고가 발생한 시점이며 지속 시간을 뜻하지 않아요.',
          style: TextStyle(color: AppColor.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // 시각이 몰려 있어도 확인할 수 있도록 가로 스크롤 제공
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 680,
            height: 220,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 12),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: durationSeconds,
                  minY: -0.5,
                  maxY: 1.5,
                  clipData: const FlClipData.all(),
                  lineTouchData: const LineTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 1,
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
                        reservedSize: 62,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if ((value - 1).abs() < 0.001) {
                            return const Text(
                              '자세 경고',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.postureText,
                              ),
                            );
                          }

                          if (value.abs() < 0.001) {
                            return const Text(
                              '졸음 감지',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.drowsinessText,
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        interval: durationSeconds / 4,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              TimeFormatter.toHms(value.round()),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    _eventDots(
                      logs: validLogs,
                      type: 'posture',
                      row: 1,
                      color: AppColor.postureText,
                    ),
                    _eventDots(
                      logs: validLogs,
                      type: 'drowsiness',
                      row: 0,
                      color: AppColor.drowsinessText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (session.detectionLogs.isEmpty)
          const Text(
            '전달받은 감지 로그가 없어요.',
            style: TextStyle(color: AppColor.textSecondary),
          ),
        if (outsideCount > 0)
          Text(
            '세션 시간 범위 밖의 로그 ${outsideCount}개는 '
            '그래프에서 제외했어요. 아래 목록에는 표시해요.',
            style: const TextStyle(color: AppColor.error),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        title: const Text('학습 기록 상세'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. 학습 요약
          Text(
            session.studyDate,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            TimeFormatter.toHms(session.totalStudySeconds),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text('시작: ${_timeText(session.startTime)}'),
          Text('종료: ${_timeText(session.endTime)}'),
          const SizedBox(height: 8),
          const Text(
            '시각은 한국 표준시(KST) 기준이에요.',
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('자세 경고: ${session.postureWarningCount}회'),
          Text('졸음 감지: ${session.drowsinessCount}회'),

          // 2. 발생 시점 그래프
          const SizedBox(height: 28),
          const Text(
            '경고 발생 시점',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _eventChart(),

          // 3. 실제 감지 시각 목록
          const SizedBox(height: 28),
          const Text(
            '감지 시각 목록',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '횟수는 서버의 집계값이고, 아래 목록은 전달받은 개별 로그예요.',
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
          const SizedBox(height: 12),
          if (session.detectionLogs.isEmpty) const Text('표시할 감지 로그가 없어요.'),
          ...session.detectionLogs.map((log) {
            final isPosture = log.type == 'posture';
            final isDrowsiness = log.type == 'drowsiness';

            final label = isPosture
                ? '자세 경고'
                : isDrowsiness
                ? '졸음 감지'
                : '기타 감지';

            final color = isPosture
                ? AppColor.postureText
                : isDrowsiness
                ? AppColor.drowsinessText
                : AppColor.textSecondary;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isPosture
                    ? Icons.accessibility_new
                    : Icons.notifications_outlined,
                color: color,
              ),
              title: Text(label, style: TextStyle(color: color)),
              subtitle: Text(_timeText(log.time)),
            );
          }),
        ],
      ),
    );
  }
}
