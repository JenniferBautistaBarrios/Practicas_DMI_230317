import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/season_icons.dart';
import '../../../domain/entities/season.dart';
import '../../providers/preferences_provider.dart';

/// Shows a short seasonal welcome before opening the requested screen.
class AppStartupGate extends StatefulWidget {
  final Widget child;

  const AppStartupGate({super.key, required this.child});

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _particles;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _particles = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _timer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _particles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) return widget.child;
    final colors = Theme.of(context).colorScheme;
    final season = context.watch<PreferencesProvider>().season;
    // Every supported season uses the redesigned welcome throughout the year.
    final useSeasonalWelcome = Season.values.contains(season);
    final backgroundStart = switch (season) {
      Season.normal => const Color(0xFF282273),
      Season.halloween => const Color(0xFF321345),
      Season.christmas => const Color(0xFF3B0714),
      Season.valentines => const Color(0xFF570D36),
    };
    final backgroundEnd = switch (season) {
      Season.normal => const Color(0xFF55499B),
      Season.halloween => const Color(0xFF68265C),
      Season.christmas => const Color(0xFF79162A),
      Season.valentines => const Color(0xFF9B2856),
    };

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [backgroundStart, backgroundEnd],
              ),
            ),
          ),
          if (useSeasonalWelcome)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particles,
                  builder: (context, _) => CustomPaint(
                    painter: _ChristmasBackdropPainter(progress: _particles.value),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particles,
                builder: (context, _) => CustomPaint(
                  painter: _SeasonParticlePainter(
                    season: season,
                    progress: _particles.value,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -90,
            right: -55,
            child: _GlowCircle(
              color: Colors.white.withValues(alpha: .10),
              size: 250,
            ),
          ),
          Positioned(
            bottom: -115,
            left: -65,
            child: _GlowCircle(
              color: Colors.white.withValues(alpha: .08),
              size: 280,
            ),
          ),
          if (useSeasonalWelcome)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: .84, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Opacity(
                  opacity: scale.clamp(0.0, 1.0).toDouble(),
                  child: Transform.scale(scale: scale, child: child),
                ),
                child: _SeasonalWelcome(season: season),
              ),
            )
          else
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: .82, end: 1),
              duration: const Duration(milliseconds: 850),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Opacity(
                opacity: scale.clamp(0.0, 1.0).toDouble(),
                child: Transform.scale(scale: scale, child: child),
              ),
              child: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 26),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .98),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: .9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .22),
                      blurRadius: 36,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 158,
                      height: 158,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: .08),
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.primary.withValues(alpha: .16), width: 2),
                        boxShadow: [
                          BoxShadow(color: colors.primary.withValues(alpha: .16), blurRadius: 24, spreadRadius: 2),
                        ],
                      ),
                      child: Image.asset(
                        SeasonIcons.assetFor(season),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'KittyTokTik',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu rincón de videos\npara disfrutar cada día.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6C5A68),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 110,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor: colors.primary.withValues(alpha: .15),
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonalWelcome extends StatelessWidget {
  final Season season;

  const _SeasonalWelcome({required this.season});

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFFFD982);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 260,
              height: 260,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF0B5), Color(0xFFB87522), Color(0xFFFFD982), Color(0xFF8D511B)],
                ),
                border: Border.all(color: const Color(0xFFFFEAB0), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x99F3B94D), blurRadius: 34, spreadRadius: 3),
                  BoxShadow(color: Color(0x99000000), blurRadius: 28, offset: Offset(0, 16)),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8D511B), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(SeasonIcons.assetFor(season), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFEAB0), Color(0xFFD99A3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD982).withValues(alpha: .34),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF5A1020),
                    size: 29,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: const [
                        Shadow(color: Color(0xFFFFD982), blurRadius: 14),
                        Shadow(
                          color: Color(0xCC21040B),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    children: const [
                      TextSpan(
                        text: 'Kitty',
                        style: TextStyle(color: Color(0xFFFF7180)),
                      ),
                      TextSpan(
                        text: 'TokTik',
                        style: TextStyle(color: Color(0xFFFFD982)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tu rincón de videos\npara disfrutar cada día',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: gold,
                height: 1.45,
                fontWeight: FontWeight.w500,
                letterSpacing: .25,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 186,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: .18),
                      color: gold,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Icon(Icons.auto_awesome, size: 18, color: gold.withValues(alpha: .95)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChristmasBackdropPainter extends CustomPainter {
  final double progress;
  const _ChristmasBackdropPainter({required this.progress});

  static const _lights = <Offset>[
    Offset(.08, .13), Offset(.26, .08), Offset(.47, .16), Offset(.72, .09), Offset(.91, .19),
    Offset(.15, .39), Offset(.84, .42), Offset(.07, .68), Offset(.92, .72), Offset(.27, .88),
    Offset(.68, .86), Offset(.48, .73), Offset(.55, .31), Offset(.38, .52), Offset(.76, .58),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _lights.length; i++) {
      final p = _lights[i];
      final pulse = .45 + .35 * (math.sin(progress * math.pi * 2 + i * 1.7) + 1) / 2;
      final center = Offset(p.dx * size.width, p.dy * size.height);
      final radius = 4.0 + (i % 3) * 2;
      canvas.drawCircle(center, radius * 3.4, Paint()..color = const Color(0xFFFFCB66).withValues(alpha: pulse * .13)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      canvas.drawCircle(center, radius, Paint()..color = (i.isEven ? const Color(0xFFFFD889) : const Color(0xFFFF6676)).withValues(alpha: pulse));
    }

    // Fine, low contrast grain gives the burgundy backdrop a soft leather feel.
    final grain = Paint()..color = const Color(0xFFFFE2C2).withValues(alpha: .035);
    for (var i = 0; i < 260; i++) {
      final x = ((i * 73) % 997) / 997 * size.width;
      final y = ((i * 193 + 31) % 991) / 991 * size.height;
      canvas.drawCircle(Offset(x, y), i.isEven ? .65 : .4, grain);
    }
  }

  @override
  bool shouldRepaint(covariant _ChristmasBackdropPainter oldDelegate) => oldDelegate.progress != progress;
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

class _SeasonParticlePainter extends CustomPainter {
  final Season season;
  final double progress;

  const _SeasonParticlePainter({required this.season, required this.progress});

  static final _particles = List<_Particle>.generate(34, (index) {
    final x = ((index * 37) % 101) / 100;
    final y = ((index * 61 + 13) % 100) / 100;
    final size = 13.0 + ((index * 11) % 15);
    final speed = .52 + ((index * 7) % 45) / 100;
    final phase = (index * 2.399) % (math.pi * 2);
    return _Particle(x, y, size, speed, phase);
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    for (var index = 0; index < _particles.length; index++) {
      final particle = _particles[index];
      final yProgress = (particle.startY + progress * particle.speed) % 1.18;
      final y = (yProgress - .10) * size.height;
      final sway = math.sin(progress * math.pi * 2 + particle.phase) * 17;
      final x = particle.x * size.width + sway;
      final center = Offset(x, y);
      final rotation = math.sin(progress * math.pi * 2 + particle.phase) * .30;
      final opacity = .58 + (math.sin(particle.phase) + 1) * .12;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      switch (season) {
        case Season.valentines:
          _paintHeart(canvas, particle.size, _heartColor(index, opacity));
          break;
        case Season.halloween:
          _paintPumpkin(canvas, particle.size, opacity);
          break;
        case Season.christmas:
          _paintCandyCane(canvas, particle.size, opacity);
          break;
        case Season.normal:
          _paintSparkle(canvas, particle.size, index, opacity);
          break;
      }
      canvas.restore();
    }
  }

  Color _heartColor(int index, double opacity) =>
      (index.isEven ? const Color(0xFFFFD8E6) : const Color(0xFFFF708F))
          .withValues(alpha: opacity);

  void _paintSparkle(Canvas canvas, double size, int index, double opacity) {
    final color = (index.isEven ? const Color(0xFFFFE5A4) : Colors.white)
        .withValues(alpha: opacity);
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * .10 < 1.4 ? 1.4 : size * .10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-size * .42, 0), Offset(size * .42, 0), paint);
    canvas.drawLine(Offset(0, -size * .42), Offset(0, size * .42), paint);
    canvas.drawCircle(Offset.zero, size * .13, Paint()..color = color);
  }

  void _paintHeart(Canvas canvas, double size, Color color) {
    final path = Path()
      ..moveTo(0, size * .92)
      ..cubicTo(-size * .12, size * .76, -size * .82, size * .34, -size * .72, size * .08)
      ..cubicTo(-size * .64, -size * .16, -size * .22, -size * .18, 0, size * .10)
      ..cubicTo(size * .22, -size * .18, size * .64, -size * .16, size * .72, size * .08)
      ..cubicTo(size * .82, size * .34, size * .12, size * .76, 0, size * .92)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintPumpkin(Canvas canvas, double size, double opacity) {
    final body = Paint()..color = const Color(0xFFFFA12B).withValues(alpha: opacity);
    final shade = Paint()..color = const Color(0xFFE96C16).withValues(alpha: opacity);
    final stem = Paint()..color = const Color(0xFF9BCB79).withValues(alpha: opacity);
    canvas.drawOval(Rect.fromLTWH(-size * .46, -size * .26, size * .92, size * .76), body);
    canvas.drawOval(Rect.fromLTWH(-size * .46, -size * .12, size * .48, size * .60), shade);
    canvas.drawOval(Rect.fromLTWH(-size * .02, -size * .12, size * .48, size * .60), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size * .10, -size * .50, size * .20, size * .30),
        const Radius.circular(3),
      ),
      stem,
    );
  }

  void _paintCandyCane(Canvas canvas, double size, double opacity) {
    final path = Path()
      ..moveTo(size * .23, size * .48)
      ..lineTo(size * .23, -size * .12)
      ..cubicTo(size * .23, -size * .48, -size * .03, -size * .50, -size * .22, -size * .42)
      ..cubicTo(-size * .49, -size * .30, -size * .45, -size * .03, -size * .25, size * .03);
    final white = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * .28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, white);

    final red = Paint()
      ..color = const Color(0xFFFF7586).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * .13
      ..strokeCap = StrokeCap.round;
    for (final offset in [-.02, .18, .37]) {
      canvas.drawLine(
        Offset(size * .09, size * offset),
        Offset(size * .37, size * (offset - .10)),
        red,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SeasonParticlePainter oldDelegate) =>
      oldDelegate.season != season || oldDelegate.progress != progress;
}

class _Particle {
  final double x;
  final double startY;
  final double size;
  final double speed;
  final double phase;

  const _Particle(this.x, this.startY, this.size, this.speed, this.phase);
}
