class StatisticsDayModel {
  // 날짜별 통계 정보
  final String date;
  final int totalStudySeconds;

  // 월별 응답에만 포함되는 세션 수
  final int? sessionCount;

  StatisticsDayModel({
    required this.date,
    required this.totalStudySeconds,
    required this.sessionCount,
  });

  factory StatisticsDayModel.fromJson(Map<String, dynamic> json) {
    return StatisticsDayModel(
      date: json['date'] as String,
      totalStudySeconds: (json['total_study_seconds'] as num).toInt(),
      sessionCount: (json['session_count'] as num?)?.toInt(),
    );
  }
}

class MonthlyStatisticsModel {
  // 월별 통계 정보
  final String month;
  final int totalStudySeconds;
  final int studyDayCount;
  final List<StatisticsDayModel> days;

  MonthlyStatisticsModel({
    required this.month,
    required this.totalStudySeconds,
    required this.studyDayCount,
    required this.days,
  });

  factory MonthlyStatisticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return MonthlyStatisticsModel(
      month: data['month'] as String,
      totalStudySeconds: (data['total_study_seconds'] as num).toInt(),
      studyDayCount: (data['study_day_count'] as num).toInt(),
      days: (data['days'] as List<dynamic>)
          .map(
            (item) => StatisticsDayModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class WeeklyStatisticsModel {
  // 주별 통계 정보
  final String startDate;
  final String endDate;
  final int totalStudySeconds;
  final List<StatisticsDayModel> days;

  WeeklyStatisticsModel({
    required this.startDate,
    required this.endDate,
    required this.totalStudySeconds,
    required this.days,
  });

  factory WeeklyStatisticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return WeeklyStatisticsModel(
      startDate: data['start_date'] as String,
      endDate: data['end_date'] as String,
      totalStudySeconds: (data['total_study_seconds'] as num).toInt(),
      days: (data['days'] as List<dynamic>)
          .map(
            (item) => StatisticsDayModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}