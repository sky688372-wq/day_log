import 'package:day_log/core/providers/user_info_provider.dart';
import 'package:day_log/core/theme/app_color.dart';
import 'package:day_log/core/utils/snack_bar_helper.dart';
import 'package:day_log/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  //관련 사이트 주소
  static const String _appGithubUrl =
      'https://github.com/sky688372-wq/day_log';

  static const String _projectGithubUrl =
      'https://github.com/cowbrush03/MDP2026-Study';

  // TODO: 포트폴리오 완성 후 따옴표 안에 https://로 시작하는 주소 입력
  static const String _portfolioUrl = '';

  //현재 온보딩에서 사용하는 Storyset 일러스트 출처
  static const String _illustrationUrl = 'https://storyset.com';

  //앱 버전
  String _appVersion = '확인 중';

  //로그아웃 처리 상태
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  // 1. 설치된 앱의 실제 버전 조회
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      if (!mounted) return;

      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _appVersion = '확인 불가';
      });
    }
  }

  // 2. 외부 사이트 열기
  Future<void> _openUrl(
      String address, {
        String emptyMessage = '아직 준비 중인 페이지예요.',
      }) async {
    final value = address.trim();

    //주소가 아직 입력되지 않은 경우
    if (value.isEmpty) {
      SnackBarHelper.show(context, emptyMessage);
      return;
    }

    final uri = Uri.tryParse(value);

    //웹 사이트 주소인지 확인
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      SnackBarHelper.show(
        context,
        '사이트 주소를 확인해주세요.',
      );
      return;
    }

    try {
      //외부 브라우저 또는 해당 링크를 처리하는 앱으로 이동
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      if (!opened) {
        SnackBarHelper.show(
          context,
          '페이지를 열지 못했어요. 잠시 후 다시 시도해주세요.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      SnackBarHelper.show(
        context,
        '페이지를 열지 못했어요. 연결 상태를 확인해주세요.',
      );
    }
  }

  // 3. 간단한 안내 표시
  void _showInfo({
    required String title,
    required String content,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColor.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                height: 1.6,
                color: AppColor.textSecondary,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: AppColor.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 4. 로그아웃 확인
  Future<void> _confirmLogout() async {
    if (_isLoggingOut || context.read<UserInfoProvider>().isLoading) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColor.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '로그아웃할까요?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              '이 기기에 저장된 자동 로그인 정보가 삭제돼요.\n'
                  '학습 기록은 계정에 그대로 남아 있어요.',
              style: TextStyle(
                height: 1.6,
                color: AppColor.textSecondary,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: AppColor.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.error,
                foregroundColor: AppColor.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    //취소하거나 다이얼로그 밖을 누르면 진행하지 않음
    if (!mounted || confirmed != true) return;

    await _logout();
  }

  // 5. 로그아웃 처리
  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final userInfoProvider = context.read<UserInfoProvider>();

    if (userInfoProvider.isLoading) return;

    setState(() {
      _isLoggingOut = true;
    });

    final success = await userInfoProvider.logout();

    if (!mounted) return;

    if (success) {
      //이전 사용자 화면으로 돌아갈 수 없도록 기존 화면 제거
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
            (route) => false,
      );
    } else {
      setState(() {
        _isLoggingOut = false;
      });

      SnackBarHelper.show(
        context,
        userInfoProvider.errorMessage ?? '로그아웃하지 못했어요.',
      );
    }
  }

  // 6. 메뉴 카드
  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    //배경과 터치 효과를 같은 Material에 표시
    return Material(
      color: AppColor.surfaceCard,
      elevation: 2,
      shadowColor: AppColor.textPrimary.withValues(alpha: 0.16),
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  // 7. 공통 메뉴
  Widget _menu({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
    bool external = false,
    Color iconColor = AppColor.primary,
    Color iconBackground = AppColor.primaryContainer,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      horizontalTitleGap: 12,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 21,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColor.textSecondary,
        ),
      ),
      trailing: Icon(
        external ? Icons.open_in_new : Icons.chevron_right,
        size: external ? 17 : 22,
        color: AppColor.textHint,
      ),
      onTap: _isLoggingOut ? null : onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userInfoProvider = context.watch<UserInfoProvider>();

    final name = userInfoProvider.loginResponse?.name?.trim();
    final email = userInfoProvider.email?.trim();

    final greeting = name == null || name.isEmpty
        ? '반가워요!'
        : '$name님, 반가워요!';

    final hasPortfolio = _portfolioUrl.trim().isNotEmpty;

    return ColoredBox(
      color: AppColor.surfaceSunken,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            28 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            // 1. 화면 제목
            const Text(
              '마이',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // 2. 사용자 정보
            //프로필 아이콘 없이 색상과 여백으로 구분
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.textPrimary.withValues(alpha: 0.26),
                    blurRadius: 10,
                    spreadRadius: -3,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '나의 오늘로그',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email == null || email.isEmpty
                        ? '이메일 정보를 확인할 수 없어요.'
                        : email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '차곡차곡 쌓아가는\n나만의 공부 이야기',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. 이용 안내
            _sectionCard(
              title: '이용 안내',
              children: [
                _menu(
                  title: '학습 기록 등록 방법',
                  icon: Icons.qr_code_scanner,
                  onTap: () {
                    _showInfo(
                      title: '학습 기록 등록 방법',
                      content:
                      '오늘로그는 좌석에서 만들어진 학습 결과를 '
                          'QR로 등록하는 방식의 앱이에요.\n\n'
                          '학습을 마친 뒤 좌석 화면에 표시된 QR을 '
                          '오늘로그에서 스캔하면, 로그인한 계정의 '
                          '학습 기록으로 저장하는 흐름이에요.\n\n'
                          '하단 QR 버튼을 누르고 카메라로 좌석 QR을 비춰주세요.',
                    );
                  },
                ),
                _menu(
                  title: '통계 확인 방법',
                  icon: Icons.bar_chart_rounded,
                  onTap: () {
                    _showInfo(
                      title: '통계 확인 방법',
                      content:
                      '아래 통계 탭에서 등록된 학습 기록을 확인할 수 있어요.\n\n'
                          '전체 통계\n'
                          '월별 총 학습 시간과 학습일 수, '
                          '주별 학습 시간 그래프를 확인해요.\n\n'
                          '날짜별 기록\n'
                          '달력에서 날짜를 선택하면 '
                          '그날의 학습 시간과 세션 목록이 표시돼요.\n\n'
                          '세션 상세\n'
                          '세션을 누르면 자세 경고와 졸음이 감지된 '
                          '시점을 그래프와 목록으로 확인할 수 있어요.\n\n'
                          '기록이 없는 날짜는 QR 등록 여부도 확인해주세요.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. 프로젝트 소개와 관련 링크
            _sectionCard(
              title: '오늘로그 소개',
              children: [
                _menu(
                  title: '프로젝트 소개',
                  icon: Icons.auto_stories_outlined,
                  iconColor: AppColor.secondary,
                  iconBackground: AppColor.secondaryContainer,
                  onTap: () {
                    _showInfo(
                      title: '오늘로그 소개',
                      content:
                      '오늘로그는 AI 스마트 학습 좌석 프로젝트의 '
                          '학습 기록 앱이에요.\n\n'
                          '좌석에서 만들어진 학습 결과를 등록하고, '
                          '날짜별 기록과 학습 시간, 자세·졸음 감지 정보를 '
                          '확인하는 것을 목표로 해요.\n\n'
                          '앱에서 좌석의 하드웨어를 직접 제어하지는 않아요.\n\n'
                          '매일의 공부를 기록하며 '
                          '나만의 공부 흐름을 확인해보세요.',
                    );
                  },
                ),
                _menu(
                  title: '스마트 학습 좌석 GitHub',
                  icon: Icons.devices_outlined,
                  iconColor: AppColor.secondary,
                  iconBackground: AppColor.secondaryContainer,
                  external: true,
                  onTap: () {
                    _openUrl(_projectGithubUrl);
                  },
                ),
                _menu(
                  title: '오늘로그 앱 GitHub',
                  icon: Icons.code_rounded,
                  iconColor: AppColor.secondary,
                  iconBackground: AppColor.secondaryContainer,
                  external: true,
                  onTap: () {
                    _openUrl(_appGithubUrl);
                  },
                ),
                _menu(
                  title: '개발자 포트폴리오',
                  subtitle: hasPortfolio ? null : '준비 중이에요',
                  icon: Icons.language_rounded,
                  iconColor: AppColor.secondary,
                  iconBackground: AppColor.secondaryContainer,
                  external: true,
                  onTap: () {
                    _openUrl(
                      _portfolioUrl,
                      emptyMessage: '포트폴리오를 준비 중이에요.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. 앱 정보
            _sectionCard(
              title: '앱 정보',
              children: [
                _menu(
                  title: '일러스트 출처',
                  subtitle: '온보딩 일러스트 · Storyset',
                  icon: Icons.palette_outlined,
                  iconColor: AppColor.textSecondary,
                  iconBackground: AppColor.surfaceSunken,
                  external: true,
                  onTap: () {
                    _openUrl(_illustrationUrl);
                  },
                ),
                _menu(
                  title: '오픈소스 라이선스',
                  icon: Icons.description_outlined,
                  iconColor: AppColor.textSecondary,
                  iconBackground: AppColor.surfaceSunken,
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: '오늘로그',
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  horizontalTitleGap: 12,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.surfaceSunken,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 21,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  title: const Text(
                    '앱 버전',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    _appVersion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 6. 로그아웃
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.error,
                  foregroundColor: AppColor.onError,
                  disabledBackgroundColor: AppColor.errorContainer,
                  disabledForegroundColor: AppColor.error,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isLoggingOut || userInfoProvider.isLoading
                    ? null
                    : _confirmLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                ),
                label: Text(
                  _isLoggingOut ? '로그아웃 중...' : '로그아웃',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}