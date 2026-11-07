import 'package:day_log/core/services/api_service.dart';
import 'package:day_log/core/services/server_address_storage_service.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/core/utils/snack_bar_helper.dart';
import 'package:day_log/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class DevModeScreen extends StatefulWidget {
  const DevModeScreen({super.key});

  @override
  State<DevModeScreen> createState() => _DevModeScreenState();
}

class _DevModeScreenState extends State<DevModeScreen> {
  //저장된 서버 주소 관리
  final ServerAddressStorageService _storageService =
  ServerAddressStorageService();

  //서버 주소 입력창
  final TextEditingController _addressController = TextEditingController();

  //저장된 주소 확인 중 여부
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  //저장된 서버 주소 불러오기
  Future<void> _loadSavedAddress() async {
    String address = ApiService.defaultServerAddress;

    try {
      final saved = await _storageService.readServerAddress();

      if (saved != null && saved.trim().isNotEmpty) {
        address = saved;
      }
    } catch (e) {
      //읽지 못하면 기본 주소 사용
      print('서버 주소 읽기 오류: $e');
    }

    if (!mounted) return;

    _addressController.text = address;

    setState(() {
      _isLoading = false;
    });
  }

  //주소를 적용하고 스플래시 화면으로 이동
  Future<void> _applyAndContinue() async {
    //공백, 끝의 /, 끝의 /api/v1 제거
    final address = _addressController.text
        .trim()
        .replaceAll(RegExp(r'/+$'), '')
        .replaceFirst(RegExp(r'/api/v1$'), '');

    //http 또는 https 주소인지 확인
    final uri = Uri.tryParse(address);
    final isValid =
        uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty;

    if (!isValid) {
      SnackBarHelper.show(
        context,
        '주소 형식이 올바르지 않아요. 예: http://10.0.2.2:8000',
      );
      return;
    }

    //이번 실행에 바로 적용
    ApiService.changeServerAddress(address);

    try {
      //다음 실행에도 쓰도록 저장
      await _storageService.saveServerAddress(address);
    } catch (e) {
      //저장에 실패해도 이번 실행에는 적용됨
      print('서버 주소 저장 오류: $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColor.primary),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // 1. 제목과 안내
              const Text(
                '개발자 모드',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '연결할 서버 주소를 확인하고\n다음으로 넘어가요.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColor.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // 2. 서버 주소 입력
              TextField(
                controller: _addressController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: '서버 주소',
                  hintText: ApiService.defaultServerAddress,
                  helperText: '이 주소 뒤에 /api/v1을 붙여서 요청해요.',
                  filled: true,
                  fillColor: AppColor.surfaceCard,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColor.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColor.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 3. 기본 주소로 되돌리기
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.textSecondary,
                  ),
                  onPressed: () {
                    _addressController.text =
                        ApiService.defaultServerAddress;
                  },
                  child: const Text('기본 주소로 되돌리기'),
                ),
              ),

              const SizedBox(height: 16),

              // 4. 시작 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applyAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '이 주소로 시작',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}