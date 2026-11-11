import 'dart:async';

import 'package:day_log/core/providers/user_info_provider.dart';
import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/services/study_result_service.dart';
import 'package:day_log/screens/auth/login_screen.dart';
import 'package:day_log/screens/main/tab/statistics/study_session_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class StudyResultScanScreen extends StatefulWidget {
  const StudyResultScanScreen({super.key});

  @override
  State<StudyResultScanScreen> createState() => _StudyResultScanScreenState();
}

class _StudyResultScanScreenState extends State<StudyResultScanScreen>
    with WidgetsBindingObserver {
  final _controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  String? _resultId;
  String? _error;
  bool _busy = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;
    if (state == AppLifecycleState.resumed && _resultId == null) {
      unawaited(_controller.start());
    } else if (state != AppLifecycleState.resumed) {
      unawaited(_controller.stop());
    }
  }

  Future<void> _detect(BarcodeCapture capture) async {
    if (_busy || _resultId != null) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      try {
        final trusted = Uri.tryParse(ApiService.resultWebOrigin);
        if (trusted == null ||
            !trusted.hasAuthority ||
            !['http', 'https'].contains(trusted.scheme)) {
          setState(() => _error = '학습 결과 웹 주소 설정이 필요해요.');
          return;
        }
        _resultId = parseStudyResultId(raw, trusted);
        await _claim();
        return;
      } on FormatException catch (error) {
        setState(() => _error = error.message.toString());
      }
    }
  }

  Future<void> _claim({bool login = false}) async {
    if (_busy || _resultId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _controller.stop();
      if (!mounted) return;
      var token = context.read<UserInfoProvider>().loginResponse?.token;
      if (login || token == null || token.isEmpty) {
        final authenticated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(returnAfterLogin: true),
          ),
        );
        if (!mounted) return;
        if (authenticated != true) {
          setState(() => _error = '로그인을 취소했어요. 기록은 저장하지 않았어요.');
          return;
        }
        token = context.read<UserInfoProvider>().loginResponse?.token;
      }
      if (token == null || token.isEmpty) throw const StudyResultException(401);
      final session = await StudyResultService(
        ApiService.dio,
      ).claim(_resultId!, token);
      _saved = true;
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => StudySessionDetailScreen(session: session),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on StudyResultException catch (error) {
      if (mounted)
        setState(() {
          _error = error.message;
          _needsLogin = error.status == 401;
        });
    } catch (_) {
      if (mounted) setState(() => _error = '카메라 또는 연결 상태를 확인하고 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _needsLogin = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('공부 기록 스캔')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _resultId == null
                  ? MobileScanner(
                      controller: _controller,
                      onDetect: _detect,
                      errorBuilder: (context, error) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            '카메라를 사용할 수 없어요. 휴대폰 설정에서 오늘로그의 카메라 권한을 허용한 뒤 화면을 다시 열어주세요.',
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        _saved ? Icons.check_circle : Icons.qr_code,
                        size: 96,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    '좌석 화면의 QR을 비춰주세요.\n학습 기록을 현재 로그인한 계정에 저장합니다.',
                    textAlign: TextAlign.center,
                  ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_error!, semanticsLabel: _error),
                    ),
                  if (!_busy && _resultId != null)
                    FilledButton(
                      onPressed: () => _claim(login: _needsLogin),
                      child: Text(_needsLogin ? '로그인 후 저장' : '같은 결과 다시 저장'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
