import 'package:flutter/material.dart';

class StudyToggleButton extends StatefulWidget {
  final bool isProgress;
  final Function(bool) onToggle;

  const StudyToggleButton({
    super.key,
    required this.isProgress,
    required this.onToggle,
  });

  @override
  State<StudyToggleButton> createState() => _StudyToggleButtonState();
}

class _StudyToggleButtonState extends State<StudyToggleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,  // 120 * 0.8
      height: 32, // 40 * 0.8
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // 전체 배경 (연한 회색)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // AnimatedPositioned로 슬라이딩 배경
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            left: widget.isProgress ? 0 : 48, // 진행중이면 왼쪽(0), 완료면 오른쪽(48)
            child: Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8), // 선택된 배경 (진한 회색)
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // 버튼들
          Row(
            children: [
              // 진행중 버튼
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!widget.isProgress) widget.onToggle(true);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: CustomPaint(
                        size: const Size(16, 16),
                        painter: ProgressIconPainter(isActive: widget.isProgress),
                      ),
                    ),
                  ),
                ),
              ),
              // 완료 버튼
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (widget.isProgress) widget.onToggle(false);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: CustomPaint(
                        size: const Size(16, 16),
                        painter: CompletedIconPainter(isActive: !widget.isProgress),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 진행중 아이콘 (컬러풀한 4개 네모)
class ProgressIconPainter extends CustomPainter {
  final bool isActive;

  ProgressIconPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final boxSize = size.width * 0.5;
    final gap = size.width * 0.1;

    // 색상 설정
    final colors = [
      const Color(0xFFFF9999), // 연한 빨강
      const Color(0xFFFFB366), // 연한 주황
      const Color(0xFFFFD966), // 연한 노랑
      const Color(0xFF99CC99), // 연한 초록
    ];

    // 좌상단
    final paint1 = Paint()
      ..color = colors[0]
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint1,
    );

    // 우상단
    final paint2 = Paint()
      ..color = colors[1]
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxSize + gap, 0, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint2,
    );

    // 좌하단
    final paint3 = Paint()
      ..color = colors[2]
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, boxSize + gap, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint3,
    );

    // 우하단
    final paint4 = Paint()
      ..color = colors[3]
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxSize + gap, boxSize + gap, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint4,
    );
  }

  @override
  bool shouldRepaint(ProgressIconPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}

// 완료 아이콘 (회색 4개 네모)
class CompletedIconPainter extends CustomPainter {
  final bool isActive;

  CompletedIconPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final boxSize = size.width * 0.5;
    final gap = size.width * 0.1;

    // 색상 설정 - 활성화되면 회색이 좀 더 진해짐
    final color = isActive
        ? const Color(0xFF9E9E9E)  // 진한 회색
        : const Color(0xFFD0D0D0); // 연한 회색

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 좌상단
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint,
    );

    // 우상단
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxSize + gap, 0, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint,
    );

    // 좌하단
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, boxSize + gap, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint,
    );

    // 우하단
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxSize + gap, boxSize + gap, boxSize, boxSize),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CompletedIconPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}