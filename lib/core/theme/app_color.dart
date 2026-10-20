import 'package:flutter/material.dart';

class AppColor {
  // 기본 배경과 표면
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSunken = Color(0xFFF1F5F9);
  static const Color surfaceTint = Color(0xFFEFF6FF);

  // 브랜드 색상
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF93C5FD);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 기존 코드와의 호환용
  static const Color primaryMaterial = primary;

  // 보조 색상
  static const Color secondary = Color(0xFF818CF8);
  static const Color secondaryContainer = Color(0xFFEEF2FF);
  static const Color tertiary = Color(0xFF10B981);
  static const Color tertiaryContainer = Color(0xFFECFDF5);

  // 글자와 테두리
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFC2C6D6);

  // 감지 이벤트 표시 색상
  static const Color drowsinessBackground = Color(0xFFFEF3C7);
  static const Color drowsinessText = Color(0xFFB45309);
  static const Color postureBackground = Color(0xFFE0F2FE);
  static const Color postureText = Color(0xFF0369A1);

  // 오류 표시
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
}
