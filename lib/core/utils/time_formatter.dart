class TimeFormatter { // 서버에서 데이터를 초로 받는다면 몇 시간 몇분 몇초로 돌려주기 위한 클래스
  // 인스턴스 생성 방지
  TimeFormatter._();

  // 1. 초를 시간·분·초로 나누기
  static ({int hours, int minutes, int seconds}) split(int totalSeconds) {
    // 음수는 0으로 처리
    final safe = totalSeconds < 0 ? 0 : totalSeconds;

    return (
    hours: safe ~/ 3600,
    minutes: (safe % 3600) ~/ 60,
    seconds: safe % 60,
    );
  }

  // 2. 자세한 표기: 1시간 25분 30초 (0인 단위는 생략, 전부 0이면 0초)
  static String toHms(int totalSeconds) {
    final t = split(totalSeconds);
    final parts = <String>[];

    if (t.hours > 0) parts.add('${t.hours}시간');
    if (t.minutes > 0) parts.add('${t.minutes}분');
    if (t.seconds > 0) parts.add('${t.seconds}초');

    return parts.isEmpty ? '0초' : parts.join(' ');
  }

  // 3. 간단한 표기: 1시간 25분 (초는 버림, 홈 카드처럼 가볍게 보여줄 때 사용)
  static String toHm(int totalSeconds) {
    final t = split(totalSeconds);

    // 1분이 안 되지만 기록은 있는 경우
    if (totalSeconds > 0 && t.hours == 0 && t.minutes == 0) {
      return '1분 미만';
    }

    if (t.hours == 0) return '${t.minutes}분';
    if (t.minutes == 0) return '${t.hours}시간';

    return '${t.hours}시간 ${t.minutes}분';
  }
}