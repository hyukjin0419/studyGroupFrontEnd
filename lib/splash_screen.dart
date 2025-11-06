import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import 'package:study_group_front_end/init_prefetch.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;

  // 애니메이션들
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _mergeAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _sloganOpacityAnimation;
  late Animation<double> _rotationAnimation;

  // 색상들
  final List<Color> boxColors = [
    const Color(0xFF8AB4F8), // 파란색
    const Color(0xFFA7E07D), // 연두색
    const Color(0xFFFFAB91), // 코랄
    const Color(0xFFB39DDB), // 보라색
  ];

  final Color finalColor = const Color(0xFF73B4E3); // 메인 브랜드 컬러

  @override
  void initState() {
    super.initState();
    // 메인 컨트롤러 (2초)
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 회전 컨트롤러
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Phase 1: 박스 등장 (0~0.2초)
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.1, curve: Curves.elasticOut),
    ));

    // Phase 2: 체크 애니메이션 (0.2~0.4초)
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.4, curve: Curves.easeInOut),
    ));

    // Phase 3: 융합 애니메이션 (0.4~0.7초)
    _mergeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeInOutCubic),
    ));

    // 회전 애니메이션
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Phase 4: 텍스트 애니메이션 (0.7~0.9초)
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 0.85, curve: Curves.easeIn),
    ));

    // 슬로건 애니메이션 (0.8~1.0초)
    _sloganOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    ));

    // 애니메이션 시작
    _mainController.forward();

    // 융합 시점에 회전 시작
    _mainController.addListener(() {
      if (_mainController.value >= 0.4 && _mainController.value < 0.41) {
        _rotationController.forward();
      }
    });

    // 2초 후 메인 화면으로 이동
    Future.delayed(const Duration(milliseconds: 3000), () {
      _initApp();
    });
  }

  Future<void> _initApp() async {
    final isLoggedIn = await initIfLoggedIn(context);

    if (!mounted) return;

    if (isLoggedIn) {
      context.go('/personal');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_mainController, _rotationController]),
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 체크박스 영역
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 4개의 체크박스
                      if (_mergeAnimation.value < 1.0)
                        ..._buildCheckboxes(),

                      // 통합된 체크박스
                      if (_mergeAnimation.value > 0.3)
                        _buildMergedCheckbox(),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // SyncMate 텍스트
                AnimatedOpacity(
                  opacity: _textOpacityAnimation.value,
                  duration: const Duration(milliseconds: 200),
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - _textOpacityAnimation.value)),
                    child: const Text(
                      'SyncMate',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 슬로건
                AnimatedOpacity(
                  opacity: _sloganOpacityAnimation.value,
                  duration: const Duration(milliseconds: 200),
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - _sloganOpacityAnimation.value)),
                    child: const Text(
                      '목표를 동기화하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF73675C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildCheckboxes() {
    List<Widget> boxes = [];

    for (int i = 0; i < 4; i++) {
      // 각 박스의 위치 계산
      double startX = -54 + (i * 36.0);
      double endX = 0;
      double endY = 0;

      // 융합 애니메이션 중 위치
      double currentX = startX + (endX - startX) * _mergeAnimation.value;
      double currentY = endY * _mergeAnimation.value;

      // 회전 반경
      double radius = 30 * (1 - _mergeAnimation.value);

      if (_rotationController.isAnimating) {
        double angle = _rotationAnimation.value + (i * math.pi / 2);
        currentX = radius * math.cos(angle);
        currentY = radius * math.sin(angle);
      }

      boxes.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: 150 + currentX - 18,
          top: 100 + currentY - 18,
          child: Transform.scale(
            scale: _scaleAnimation.value * (1 - _mergeAnimation.value * 0.3),
            child: Opacity(
              opacity: 1 - _mergeAnimation.value,
              child: _buildSingleCheckbox(i),
            ),
          ),
        ),
      );
    }

    return boxes;
  }

  Widget _buildSingleCheckbox(int index) {
    bool isChecked = _checkAnimation.value > 0;
    Color boxColor = boxColors[index];

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isChecked ? boxColor : Colors.transparent,
        border: Border.all(
          color: boxColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isChecked
            ? [
          BoxShadow(
            color: boxColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ]
            : [],
      ),
      child: isChecked
          ? TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return CustomPaint(
            painter: CheckmarkPainter(
              progress: value,
              color: Colors.white,
            ),
          );
        },
      )
          : null,
    );
  }

  Widget _buildMergedCheckbox() {
    double scale = 0.5 + (_mergeAnimation.value * 1.0);

    return Transform.scale(
      scale: scale,
      child: AnimatedOpacity(
        opacity: _mergeAnimation.value,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: finalColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: finalColor.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: _mergeAnimation.value > 0.8
              ? CustomPaint(
            painter: CheckmarkPainter(
              progress: (_mergeAnimation.value - 0.8) * 5,
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
              : null,
        ),
      ),
    );
  }
}

// 체크마크 그리기
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;

    path.moveTo(startX, startY);

    if (progress > 0) {
      final midX = size.width * 0.45;
      final midY = size.height * 0.65;
      final endX = size.width * 0.75;
      final endY = size.height * 0.35;

      if (progress <= 0.5) {
        double localProgress = progress * 2;
        path.lineTo(
          startX + (midX - startX) * localProgress,
          startY + (midY - startY) * localProgress,
        );
      } else {
        path.lineTo(midX, midY);
        double localProgress = (progress - 0.5) * 2;
        path.lineTo(
          midX + (endX - midX) * localProgress,
          midY + (endY - midY) * localProgress,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}