import 'package:flutter/material.dart';

/// Cinemapedia mark: an open reference book topped with a film clapper.
/// [progress] reveals the illustration from left to right on the splash screen.
class CinemapediaLogo extends StatelessWidget {
  final double size;
  final double progress;

  const CinemapediaLogo({
    super.key,
    this.size = 28,
    this.progress = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: CinemapediaLogoPainter(progress: progress),
    );
  }
}

class CinemapediaLogoPainter extends CustomPainter {
  final double progress;

  CinemapediaLogoPainter({required this.progress});

  static const _ink = Color(0xFF8E285B);
  static const _pink = Color(0xFFD63384);
  static const _pale = Color(0xFFFFE4EF);
  static const _paper = Color(0xFFFFFCFE);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.clipRect(
      Rect.fromLTWH(0, 0, 100 * progress.clamp(0.0, 1.0).toDouble(), 100),
    );

    final background = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 3, 94, 94),
      const Radius.circular(25),
    );
    canvas.drawRRect(background, Paint()..color = _pale);

    final leftPage = Path()
      ..moveTo(13, 32)
      ..cubicTo(26, 27, 39, 29, 50, 37)
      ..lineTo(50, 80)
      ..cubicTo(39, 72, 26, 70, 13, 75)
      ..close();
    final rightPage = Path()
      ..moveTo(50, 37)
      ..cubicTo(61, 29, 74, 27, 87, 32)
      ..lineTo(87, 75)
      ..cubicTo(74, 70, 61, 72, 50, 80)
      ..close();

    canvas.drawPath(leftPage, Paint()..color = _paper);
    canvas.drawPath(rightPage, Paint()..color = Colors.white);
    final pageOutline = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(leftPage, pageOutline);
    canvas.drawPath(rightPage, pageOutline);
    canvas.drawLine(const Offset(50, 37), const Offset(50, 80), pageOutline);

    final pageLine = Paint()
      ..color = const Color(0xFFE7A9C4)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(21, 45), const Offset(40, 48), pageLine);
    canvas.drawLine(const Offset(21, 55), const Offset(40, 58), pageLine);
    canvas.drawLine(const Offset(60, 48), const Offset(79, 45), pageLine);
    canvas.drawLine(const Offset(60, 58), const Offset(79, 55), pageLine);

    final clapper = Path()
      ..moveTo(27, 25)
      ..lineTo(73, 25)
      ..lineTo(82, 13)
      ..lineTo(36, 13)
      ..close();
    canvas.drawPath(clapper, Paint()..color = _ink);
    final clapperBody = RRect.fromRectAndRadius(
      const Rect.fromLTWH(27, 22, 55, 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(clapperBody, Paint()..color = _pink);
    final perforation = Paint()..color = _pale;
    for (var x = 34.0; x <= 73; x += 12) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 25, 6, 4),
          const Radius.circular(1),
        ),
        perforation,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CinemapediaLogoPainter old) => old.progress != progress;
}
