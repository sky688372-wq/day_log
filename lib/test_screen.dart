import 'dart:convert';

import 'package:day_log/core/providers/user_info_provider.dart';
import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // 조회할 날짜 입력 (YYYY-MM-DD)
  final TextEditingController _dateController = TextEditingController(
    text: '2026-11-05',
  );

  // 요청 중 여부
  bool _isLoading = false;

  // 화면에 보여줄 결과
  String _result = '아직 요청하지 않았어요.';

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 일별 통계 요청 함수
    Future<void> getDailyData() async {
      // 중복 요청 방지
      if (_isLoading) return;

      // 로그인 토큰 확인
      final token = context.read<UserInfoProvider>().loginResponse?.token;

      if (token == null || token.trim().isEmpty) {
        setState(() {
          _result = '로그인 정보가 없어요. 로그인 후 다시 시도해주세요.';
        });
        return;
      }

      // 입력한 날짜 확인
      final date = DateTime.tryParse(_dateController.text.trim());

      if (date == null) {
        setState(() {
          _result = '날짜 형식이 올바르지 않아요. 예: 2026-11-05';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _result = '요청 중...';
      });

      final response = await ApiService.tryGetDailyStatistics(
        token: token,
        date: date,
      );

      // 비동기 작업 후 화면이 남아 있는지 확인
      if (!mounted) return;

      setState(() {
        _isLoading = false;

        // 실패하면 null이 오므로 콘솔의 오류 로그 확인
        _result = response == null
            ? '요청에 실패했어요. 콘솔의 오류 코드와 오류 응답을 확인해주세요.'
            : const JsonEncoder.withIndent('  ').convert(response);
      });
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        title: const Text('일별 통계 API 테스트'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: '조회할 날짜 (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : getDailyData,
                  child: Text(_isLoading ? '요청 중...' : '일별 통계 조회'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '응답 결과',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.outline),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _result,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}