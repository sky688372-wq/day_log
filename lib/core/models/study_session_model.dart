class StudySessionModel {
  // 학습 기록 정보
  final String sessionId;
  final String studyDate;
  final int totalStudySeconds;
  final int drowsinessCount;
  final int postureWarningCount;
  final DateTime startTime;
  final DateTime endTime;
  final List<DetectionLogModel> detectionLogs;

  StudySessionModel({
    required this.sessionId,
    required this.studyDate,
    required this.totalStudySeconds,
    required this.drowsinessCount,
    required this.postureWarningCount,
    required this.startTime,
    required this.endTime,
    required this.detectionLogs,
  });

  // 1. 서버 응답을 학습 기록 모델로 변환
  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    final logs = (json['detection_logs'] as List<dynamic>)
        .map(
          (item) => DetectionLogModel.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();

    // 발생 시각 순으로 정렬
    logs.sort((a, b) => a.time.compareTo(b.time));

    return StudySessionModel(
      sessionId: json['session_id'] as String,
      studyDate: json['study_date'] as String,
      totalStudySeconds: (json['total_study_seconds'] as num).toInt(),
      drowsinessCount: (json['drowsiness_count'] as num).toInt(),
      postureWarningCount: (json['posture_warning_count'] as num).toInt(),
      startTime: DateTime.parse(json['start_time'] as String).toUtc(),
      endTime: DateTime.parse(json['end_time'] as String).toUtc(),
      detectionLogs: logs,
    );
  }
}

class DetectionLogModel {
  // 감지 발생 정보
  final DateTime time;
  final String type;

  DetectionLogModel({
    required this.time,
    required this.type,
  });

  // 1. 서버 응답을 감지 로그 모델로 변환
  factory DetectionLogModel.fromJson(Map<String, dynamic> json) {
    return DetectionLogModel(
      time: DateTime.parse(json['time'] as String).toUtc(),
      type: json['type'] as String,
    );
  }
}