import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constant/app_color.dart';

/// Purely visual mining-themed building blocks (pickaxe, gears, rig hero,
/// hash-bit rain, coin count-up). No game logic lives here. All looping
/// animations stop when the OS "reduce motion" setting is on.

bool _reduceMotion(BuildContext context) => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// Material has no pickaxe icon, so it's drawn: a handle plus a curved head.
class PickaxeIcon extends StatelessWidget {
  final double size;
  final Color color;
  const PickaxeIcon({super.key, this.size = 32, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PickaxePainter(color));
  }
}

class _PickaxePainter extends CustomPainter {
  final Color color;
  _PickaxePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final handle = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.09;
    canvas.drawLine(Offset(s * 0.5, s * 0.95), Offset(s * 0.5, s * 0.22), handle);

    final head = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.11;
    final path = Path()
      ..moveTo(s * 0.08, s * 0.42)
      ..quadraticBezierTo(s * 0.5, -s * 0.12, s * 0.92, s * 0.42);
    canvas.drawPath(path, head);
  }

  @override
  bool shouldRepaint(_PickaxePainter old) => old.color != color;
}

/// A pickaxe swinging from its handle end, like it's striking rock.
class SwingingPickaxe extends StatefulWidget {
  final double size;
  final Color color;
  final bool swinging;
  const SwingingPickaxe({super.key, this.size = 40, this.color = Colors.white, this.swinging = true});

  @override
  State<SwingingPickaxe> createState() => _SwingingPickaxeState();
}

class _SwingingPickaxeState extends State<SwingingPickaxe> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SwingingPickaxe old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.swinging && !_reduceMotion(context);
    if (run && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!run && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final angle = -0.5 + 1.0 * Curves.easeInOut.transform(_c.value);
        return Transform.rotate(angle: angle, alignment: Alignment.bottomCenter, child: child);
      },
      child: PickaxeIcon(size: widget.size, color: widget.color),
    );
  }
}

/// A rotating gear. Use [reverse] for a second meshing gear.
class SpinningGear extends StatefulWidget {
  final double size;
  final Color color;
  final bool spinning;
  final bool reverse;
  final int seconds;
  const SpinningGear({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.spinning = true,
    this.reverse = false,
    this.seconds = 6,
  });

  @override
  State<SpinningGear> createState() => _SpinningGearState();
}

class _SpinningGearState extends State<SpinningGear> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(seconds: widget.seconds));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SpinningGear old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.spinning && !_reduceMotion(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: widget.reverse ? ReverseAnimation(_c) : _c,
      child: Icon(Icons.settings_rounded, size: widget.size, color: widget.color),
    );
  }
}

/// Gear-based replacement for the generic circular spinner.
class GearLoader extends StatelessWidget {
  final double size;
  const GearLoader({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 0, child: SpinningGear(size: size * 0.72, color: AppColor.primary, seconds: 3)),
          Positioned(
            right: 0,
            bottom: 0,
            child: SpinningGear(size: size * 0.46, color: AppColor.secondary, reverse: true, seconds: 2),
          ),
        ],
      ),
    );
  }
}

/// Soft scale + glow pulse behind a child.
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool active;
  const PulseGlow({super.key, required this.child, this.color = AppColor.warning, this.active = true});

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PulseGlow old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.active && !_reduceMotion(context);
    if (run && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!run && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Transform.scale(
          scale: 1 + 0.08 * t,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.15 + 0.3 * t), blurRadius: 12 + 14 * t)],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

enum MiningHeroState { idle, mining, ready }

/// The Mining tab's centerpiece: a rig with meshing gears, expanding signal
/// rings and rising hash bits while mining; a dim static rig when idle; a
/// pulsing coin once the session is ready to claim.
class MiningRigHero extends StatefulWidget {
  final MiningHeroState state;
  final double size;
  const MiningRigHero({super.key, required this.state, this.size = 132});

  @override
  State<MiningRigHero> createState() => _MiningRigHeroState();
}

class _MiningRigHeroState extends State<MiningRigHero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  static const _bits = ['0', '1', '1', '0', '1', '0'];
  static const _bitX = [0.18, 0.34, 0.5, 0.66, 0.8, 0.42];
  static const _bitPhase = [0.0, 0.17, 0.33, 0.5, 0.67, 0.83];

  bool get _mining => widget.state == MiningHeroState.mining;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MiningRigHero old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = _mining && !_reduceMotion(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final ready = widget.state == MiningHeroState.ready;
    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (_mining)
                for (var i = 0; i < 2; i++)
                  Builder(builder: (_) {
                    final p = (_c.value + i * 0.5) % 1;
                    return Opacity(
                      opacity: (1 - p) * 0.35,
                      child: Transform.scale(
                        scale: 0.75 + 0.55 * p,
                        child: Container(
                          width: s,
                          height: s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    );
                  }),
              Container(
                width: s * 0.86,
                height: s * 0.86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: _mining || ready ? 0.16 : 0.09),
                ),
              ),
              SpinningGear(size: s * 0.78, color: Colors.white.withValues(alpha: 0.28), spinning: _mining, seconds: 12),
              Positioned(
                right: s * 0.02,
                bottom: s * 0.06,
                child: SpinningGear(
                  size: s * 0.34,
                  color: Colors.white.withValues(alpha: 0.4),
                  spinning: _mining,
                  reverse: true,
                  seconds: 6,
                ),
              ),
              if (_mining)
                for (var i = 0; i < _bits.length; i++)
                  Builder(builder: (_) {
                    final p = (_c.value + _bitPhase[i]) % 1;
                    return Positioned(
                      left: s * _bitX[i],
                      top: s * (0.85 - 0.75 * p),
                      child: Opacity(
                        opacity: math.sin(math.pi * p) * 0.7,
                        child: Text(
                          _bits[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    );
                  }),
              if (ready)
                PulseGlow(
                  color: AppColor.warning,
                  child: Icon(Icons.toll_rounded, size: s * 0.42, color: Colors.white),
                )
              else
                Transform.scale(
                  scale: _mining ? 1 + 0.05 * math.sin(2 * math.pi * _c.value * 2) : 1,
                  child: Icon(
                    Icons.memory_rounded,
                    size: s * 0.4,
                    color: _mining ? Colors.white : Colors.white70,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// App mark used on splash/login/signup: gradient badge, slow gear, swinging pickaxe.
class MiningLogo extends StatelessWidget {
  final double size;
  const MiningLogo({super.key, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(colors: AppColor.miningGradient),
        boxShadow: [
          BoxShadow(color: AppColor.primary.withValues(alpha: 0.4), blurRadius: 28, spreadRadius: 3),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SpinningGear(size: size * 0.82, color: Colors.white.withValues(alpha: 0.22), seconds: 12),
          SwingingPickaxe(size: size * 0.5),
        ],
      ),
    );
  }
}

/// Counts up to [value] (and re-animates from the current figure on change).
class CountUp extends StatelessWidget {
  final double value;
  final Widget Function(double current) builder;
  const CountUp({super.key, required this.value, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return builder(value);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, v, _) => builder(v),
    );
  }
}
