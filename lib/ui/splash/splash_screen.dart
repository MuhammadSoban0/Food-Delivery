import 'dart:math' as math;
import 'package:flutter/material.dart';


class SplashConfig {
  const SplashConfig({
    this.topColor = const Color(0xFFFA5560),
    this.bottomColor = const Color(0xFFED1C2D),
    this.logoText = 'Foodgo',
    this.tagline = 'Hot food, delivered fast',
    this.totalDuration = const Duration(milliseconds: 5200),
    this.bikeColor = Colors.white,
    this.bikeBoxColor = const Color(0xFFFFD54F), // delivery box
    this.bikeScale = 1.0,
    this.bikeStrokeWidth = 3.0,
    this.bubbleCount = 9,
    this.showSpeedLines = true,
  });

  final Color topColor;
  final Color bottomColor;
  final String logoText;
  final String tagline;
  final Duration totalDuration;

  // Bike painter knobs
  final Color bikeColor;
  final Color bikeBoxColor;
  final double bikeScale;
  final double bikeStrokeWidth;
  final bool showSpeedLines;

  // Ambient background
  final int bubbleCount;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPLASH SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class FoodgoSplashScreen extends StatefulWidget {
  const FoodgoSplashScreen({
    super.key,
    this.config = const SplashConfig(),
    this.onFinished,
  });

  final SplashConfig config;
  final void Function(BuildContext context)? onFinished;

  @override
  State<FoodgoSplashScreen> createState() => _FoodgoSplashScreenState();
}

class _FoodgoSplashScreenState extends State<FoodgoSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _master; // drives the whole timeline
  late final AnimationController _ambient; // loops forever (bubbles / bob)

  // Timeline slices (as fractions of _master)
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _bikeProgress; // 0 → 1 = off-left → off-right

  @override
  void initState() {
    super.initState();

    _master = AnimationController(
      vsync: this,
      duration: widget.config.totalDuration,
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.05, 0.30, curve: Curves.easeOut),
    );
    _logoScale = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.05, 0.42, curve: Curves.elasticOut),
    );
    _taglineSlide = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.30, 0.50, curve: Curves.easeOutCubic),
    );
    _bikeProgress = CurvedAnimation(
      parent: _master,
      // starts early (15% in) and uses nearly the whole timeline (until 98%),
      // with a gentle ease so it cruises instead of zipping past
      curve: const Interval(0.15, 0.98, curve: Curves.easeInOutSine),
    );

    _master.forward().whenComplete(() {
      if (mounted) widget.onFinished?.call(context);
    });
  }

  @override
  void dispose() {
    _master.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_master, _ambient]),
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [cfg.topColor, cfg.bottomColor],
              ),
            ),
            child: Stack(
              children: [
                // ── ambient drifting bubbles ──
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BubblePainter(
                      t: _ambient.value,
                      count: cfg.bubbleCount,
                    ),
                  ),
                ),

                // ── logo + tagline ──
                Align(
                  alignment: const Alignment(0, -0.22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _logoFade.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.6 + 0.4 * _logoScale.value,
                          child: Text(
                            cfg.logoText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // tagline slides up & fades in
                      ClipRect(
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - _taglineSlide.value)),
                          child: Opacity(
                            opacity: _taglineSlide.value.clamp(0.0, 1.0),
                            child: Text(
                              cfg.tagline,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── delivery bike sweeping across ──
                _buildBike(size, cfg),

                // ── tiny loading dots at the bottom ──
                Align(
                  alignment: const Alignment(0, 0.86),
                  child: _LoadingDots(t: _ambient.value),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBike(Size size, SplashConfig cfg) {
    final p = _bikeProgress.value;
    if (p <= 0) return const SizedBox.shrink();

    final bikeW = 150.0 * cfg.bikeScale;
    final bikeH = 100.0 * cfg.bikeScale;

    // travels from fully off-screen left to fully off-screen right
    final x = -bikeW + p * (size.width + 2 * bikeW);
    // gentle bob while moving
    final bob = math.sin(_ambient.value * 2 * math.pi * 4) * 2.5;
    final y = size.height * 0.62 + bob;

    return Positioned(
      left: x,
      top: y,
      child: CustomPaint(
        size: Size(bikeW, bikeH),
        painter: DeliveryBikePainter(
          color: cfg.bikeColor,
          boxColor: cfg.bikeBoxColor,
          strokeWidth: cfg.bikeStrokeWidth,
          wheelRotation: p * 9 * math.pi,
          // wheels spin with travel (calmer)
          speedLines: cfg.showSpeedLines,
          speedLinePhase: _ambient.value,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DELIVERY BIKE PAINTER  (fully parameterised)
// ─────────────────────────────────────────────────────────────────────────────
class DeliveryBikePainter extends CustomPainter {
  DeliveryBikePainter({
    this.color = Colors.white,
    this.boxColor = const Color(0xFFFFD54F),
    this.strokeWidth = 3.0,
    this.wheelRotation = 0.0,
    this.speedLines = true,
    this.speedLinePhase = 0.0,
  });

  /// Main line colour of the bike + rider.
  final Color color;

  /// Fill colour of the delivery box on the back.
  final Color boxColor;

  /// Stroke width of the whole drawing.
  final double strokeWidth;

  /// Rotation (radians) applied to both wheels — animate for spinning.
  final double wheelRotation;

  /// Draw horizontal motion lines behind the bike.
  final bool speedLines;

  /// 0–1 phase to make the speed lines flicker.
  final double speedLinePhase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Reference geometry (proportional, so the painter scales freely)
    final wheelR = h * 0.18;
    final backWheel = Offset(w * 0.24, h * 0.78);
    final frontWheel = Offset(w * 0.78, h * 0.78);

    // ── wheels (with spokes that rotate) ──
    for (final c in [backWheel, frontWheel]) {
      canvas.drawCircle(c, wheelR, stroke);
      canvas.drawCircle(c, wheelR * 0.18, fill);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(wheelRotation);
      for (int i = 0; i < 3; i++) {
        final a = i * math.pi / 3;
        canvas.drawLine(
          Offset(math.cos(a) * wheelR * 0.82, math.sin(a) * wheelR * 0.82),
          Offset(-math.cos(a) * wheelR * 0.82, -math.sin(a) * wheelR * 0.82),
          stroke..strokeWidth = strokeWidth * 0.6,
        );
      }
      canvas.restore();
      stroke.strokeWidth = strokeWidth; // reset
    }

    // ── frame ──
    final pedal = Offset(w * 0.46, h * 0.74);
    final seatPost = Offset(w * 0.40, h * 0.46);
    final handleBase = Offset(w * 0.68, h * 0.46);

    final frame = Path()
      ..moveTo(backWheel.dx, backWheel.dy)
      ..lineTo(pedal.dx, pedal.dy)
      ..lineTo(seatPost.dx, seatPost.dy)
      ..lineTo(backWheel.dx, backWheel.dy)
      ..moveTo(pedal.dx, pedal.dy)
      ..lineTo(handleBase.dx, handleBase.dy)
      ..lineTo(frontWheel.dx, frontWheel.dy)
      ..moveTo(seatPost.dx, seatPost.dy)
      ..lineTo(handleBase.dx, handleBase.dy);
    canvas.drawPath(frame, stroke);

    // seat
    canvas.drawLine(
      Offset(seatPost.dx - w * 0.05, seatPost.dy - h * 0.02),
      Offset(seatPost.dx + w * 0.04, seatPost.dy - h * 0.02),
      stroke..strokeWidth = strokeWidth * 1.4,
    );
    stroke.strokeWidth = strokeWidth;

    // handlebar
    canvas.drawLine(
      handleBase,
      Offset(handleBase.dx + w * 0.03, h * 0.34),
      stroke,
    );
    canvas.drawLine(
      Offset(handleBase.dx + w * 0.03, h * 0.34),
      Offset(handleBase.dx - w * 0.04, h * 0.31),
      stroke,
    );

    // ── rider (simple, friendly) ──
    final hip = Offset(seatPost.dx + w * 0.01, seatPost.dy - h * 0.04);
    final shoulder = Offset(w * 0.52, h * 0.20);
    final head = Offset(w * 0.56, h * 0.10);

    canvas.drawLine(hip, shoulder, stroke); // torso
    canvas.drawCircle(head, h * 0.075, stroke); // head/helmet
    canvas.drawLine(
      shoulder,
      Offset(handleBase.dx + w * 0.01, h * 0.33),
      stroke,
    ); // arm
    // leg: hip → pedal
    canvas.drawLine(
      hip,
      Offset(pedal.dx - w * 0.02, pedal.dy - h * 0.06),
      stroke,
    );
    canvas.drawLine(
      Offset(pedal.dx - w * 0.02, pedal.dy - h * 0.06),
      pedal,
      stroke,
    );

    // ── delivery box on the back ──
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(backWheel.dx - w * 0.005, h * 0.30),
        width: w * 0.20,
        height: h * 0.26,
      ),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(boxRect, Paint()..color = boxColor);
    canvas.drawRRect(boxRect, stroke);
    // rack connecting box to frame
    canvas.drawLine(
      Offset(backWheel.dx, h * 0.43),
      Offset(backWheel.dx, backWheel.dy - wheelR),
      stroke,
    );

    // ── speed lines ──
    if (speedLines) {
      final lp = Paint()
        ..color = color.withOpacity(0.55)
        ..strokeWidth = strokeWidth * 0.8
        ..strokeCap = StrokeCap.round;
      final flick = (math.sin(speedLinePhase * 2 * math.pi * 6) + 1) / 2;
      for (int i = 0; i < 3; i++) {
        final y = h * (0.30 + 0.18 * i);
        final len = w * (0.10 + 0.05 * flick);
        canvas.drawLine(
          Offset(-w * 0.12 - i * w * 0.03, y),
          Offset(-w * 0.12 - i * w * 0.03 + len, y),
          lp,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DeliveryBikePainter old) =>
      old.wheelRotation != wheelRotation ||
      old.speedLinePhase != speedLinePhase ||
      old.color != color ||
      old.boxColor != boxColor ||
      old.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
//  AMBIENT BUBBLES  (soft white circles drifting up — like steam)
// ─────────────────────────────────────────────────────────────────────────────
class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.t, required this.count});

  final double t; // 0–1 looping
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7); // fixed seed → stable layout
    for (int i = 0; i < count; i++) {
      final baseX = rnd.nextDouble() * size.width;
      final speed = 0.4 + rnd.nextDouble() * 0.6;
      final radius = 6.0 + rnd.nextDouble() * 22.0;
      final phase = rnd.nextDouble();

      final progress = ((t * speed) + phase) % 1.0;
      final y = size.height * (1.1 - progress * 1.2);
      final x = baseX + math.sin(progress * math.pi * 2 + i) * 14;
      final opacity = (0.10 * (1 - progress)).clamp(0.0, 0.10);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
//  LOADING DOTS  (three pulsing dots)
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final phase = (t * 2 + i * 0.22) % 1.0;
        final pulse = (math.sin(phase * math.pi * 2) + 1) / 2;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 7 + 3 * pulse,
          height: 7 + 3 * pulse,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5 + 0.5 * pulse),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
