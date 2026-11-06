import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class SnackBarHelper {
  // 1. 기존 안내를 지우고 새로운 스낵바 표시
  static void show(BuildContext context, String message) {
    //이미 종료된 화면이라면 표시하지 않음
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColor.primary,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColor.onPrimary,
          ),
        ),
      ),
    );
  }
}
