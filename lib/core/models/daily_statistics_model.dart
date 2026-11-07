class DailyStatisticsModel {
  // 일별 통계 조회 시 받는 모델
  final String date; // 조회한 날짜 (YYYY-MM-DD)
  final int totalStudySeconds; // 하루 총 학습 시간(초)
  final int sessionCount; // 학습 기록 개수
  final List<Map<String, dynamic>> sessions; // 학습 기록 목록

  // 일반 생성자
  DailyStatisticsModel({
    required this.date,
    required this.totalStudySeconds,
    required this.sessionCount,
    required this.sessions,
  });

  // 팩토리 생성자
  factory DailyStatisticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return DailyStatisticsModel(
      date: data?['date'] as String? ?? '',
      totalStudySeconds: (data?['total_study_seconds'] as num?)?.toInt() ?? 0,
      sessionCount: (data?['session_count'] as num?)?.toInt() ?? 0,
      // todo 세션 항목의 필드를 확인한 뒤 세션 모델로 변경
      sessions:
      (data?['sessions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          [],
    );
  }
}