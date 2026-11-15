import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';

String statisticsDateText(DateTime date) {
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

Widget statisticsLoading() {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator(color: AppColor.primary)),
  );
}

Widget statisticsFailure(VoidCallback onRetry) {
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

Widget statisticsPanel({
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

Widget statisticsHeading(IconData icon, String title) {
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

Widget statisticsMonthSelector(DateTime month, ValueChanged<int> change) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        tooltip: '이전 달',
        onPressed: month.year == 2000 && month.month == 1
            ? null
            : () => change(-1),
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
            : () => change(1),
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

Widget statisticsList({
  required ScrollController controller,
  required List<Widget> children,
  required BuildContext context,
  required Future<void> Function() onRefresh,
}) {
  return RefreshIndicator(
    color: AppColor.primaryDark,
    backgroundColor: AppColor.surfaceCard,
    triggerMode: RefreshIndicatorTriggerMode.onEdge,
    onRefresh: onRefresh,
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
