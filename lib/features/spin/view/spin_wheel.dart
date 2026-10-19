import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Segment numbers in clockwise order starting at the top pointer.
const List<int> kWheelOrder = [2, 4, 7, 3, 6, 5, 8, 0, 1];

const Map<int, String> kSegmentEmoji = {
  0: '😢',
  1: '😎',
  2: '😲',
  3: '😘',
  4: '🥺',
  5: '😈',
  6: '😑',
  7: '😍',
  8: '😨',
};

const List<Color> _sliceColors = [
  Color(0xFFE5484D),
  Color(0xFFE2C541),
  Color(0xFF3FBFA8),
  Color(0xFFF08A3C),
  Color(0xFFD94FA8),
  Color(0xFF7C4DDB),
  Color(0xFF4F8DD9),
  Color(0xFF52B788),
  Color(0xFF3B6FD9),
];

/// Animated fortune wheel. The result always comes from the server; call
/// [SpinWheelState.spinTo] with that segment and await the landing.
class SpinWheel extends StatefulWidget {
  final double size;
  const SpinWheel({super.key, this.size = 280});

  @override
  State<SpinWheel> createState() => SpinWheelState();
}

class SpinWheelState extends State<SpinWheel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
  Animation<double>? _animation;
  double _angle = 0;

  static const double _slice = 2 * math.pi / 9;

  Future<void> spinTo(int segment) async {
    final index = kWheelOrder.indexOf(segment);
    if (index < 0) return;
    // Slice i is centred at (i + 0.5) * _slice clockwise from the pointer;
    // rotating the wheel clockwise by -centre brings it under the pointer.
    final centre = (index + 0.5) * _slice;
    final current = _angle % (2 * math.pi);
    var delta = (-centre - current) % (2 * math.pi);
    if (delta < 0) delta += 2 * math.pi;
    final target = _angle + 5 * 2 * math.pi + delta;

    _animation = Tween<double>(begin: _angle, end: target)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic))
      ..addListener(() => setState(() => _angle = _animation!.value));
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size + 14,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 14,
            child: Transform.rotate(
              angle: _angle,
              child: CustomPaint(size: Size(size, size), painter: _WheelPainter()),
            ),
          ),
          // Pointer.
          CustomPaint(size: const Size(24, 22), painter: _PointerPainter()),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: centre, radius: radius);
    const slice = 2 * math.pi / 9;

    for (var i = 0; i < kWheelOrder.length; i++) {
      final start = -math.pi / 2 + i * slice;
      canvas.drawArc(rect, start, slice, true, Paint()..color = _sliceColors[i]);
      canvas.drawArc(
        rect,
        start,
        slice,
        true,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final mid = start + slice / 2;
      _drawLabel(canvas, centre, radius * 0.78, mid, '${kWheelOrder[i]}', number: true);
      _drawLabel(canvas, centre, radius * 0.52, mid, kSegmentEmoji[kWheelOrder[i]]!, number: false);
    }

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = const Color(0xFF2B3A30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawCircle(centre, radius * 0.11, Paint()..color = const Color(0xFFE2B33C));
  }

  void _drawLabel(Canvas canvas, Offset centre, double r, double angle, String text, {required bool number}) {
    final pos = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
    if (number) {
      canvas.drawCircle(pos, 12, Paint()..color = const Color(0xFF1B2620));
    }
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: number ? 13 : 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    // Keep labels upright relative to the slice so they read outward.
    canvas.rotate(angle + math.pi / 2);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE2B33C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
