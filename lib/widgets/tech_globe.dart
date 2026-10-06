import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme.dart';
import 'common.dart';

/// Full-page 3D background: a globe made of the tech stack's logos, joined by a glowing network.
/// It turns slowly on its own, spins with the page scroll and tilts towards the mouse.
/// Logos nearer the viewer are larger and brighter; those behind are small and dim.
class TechGlobe extends StatefulWidget {
  const TechGlobe({super.key, required this.progress, required this.pointer});

  /// Page scroll, 0 at the top and 1 at the bottom.
  final ValueListenable<double> progress;

  /// Pointer position in -1..1 on each axis.
  final ValueListenable<Offset> pointer;

  @override
  State<TechGlobe> createState() => _TechGlobeState();
}

/// One logo on the globe: an icon from assets/icons, or a short label for brands without one.
class _Node {
  const _Node(this.label, [this.icon]);
  final String label;
  final String? icon;
}

const _nodes = [
  _Node('Flutter', 'flutter'),
  _Node('Dart', 'dart'),
  _Node('React', 'react'),
  _Node('Next.js', 'nextdotjs'),
  _Node('Node.js', 'nodedotjs'),
  _Node('Python', 'python'),
  _Node('Supabase', 'supabase'),
  _Node('Firebase', 'firebase'),
  _Node('Claude', 'anthropic'),
  _Node('Gemini', 'googlegemini'),
  _Node('OpenAI'),
  _Node('Google Cloud', 'googlecloud'),
  _Node('PostgreSQL', 'postgresql'),
  _Node('MongoDB', 'mongodb'),
  _Node('Redis', 'redis'),
  _Node('NestJS', 'nestjs'),
  _Node('Express', 'express'),
  _Node('Kotlin', 'kotlin'),
  _Node('JavaScript', 'javascript'),
  _Node('HTML5', 'html5'),
  _Node('CSS', 'css'),
  _Node('PHP', 'php'),
  _Node('Vercel', 'vercel'),
  _Node('GitHub', 'github'),
  _Node('GitLab', 'gitlab'),
  _Node('Figma', 'figma'),
  _Node('Jira', 'jira'),
  _Node('Postman', 'postman'),
  _Node('RAG'),
  _Node('MCP'),
  _Node('Pinecone'),
];

class _P {
  const _P(this.x, this.y, this.z);
  final double x, y, z;

  _P rotate(double rx, double ry) {
    final cy = math.cos(ry), sy = math.sin(ry);
    final x1 = x * cy + z * sy, z1 = -x * sy + z * cy;
    final cx = math.cos(rx), sx = math.sin(rx);
    return _P(x1, y * cx - z1 * sx, y * sx + z1 * cx);
  }
}

class _TechGlobeState extends State<TechGlobe>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  final time = ValueNotifier<double>(0);

  // Logos spread evenly over a unit sphere (Fibonacci lattice).
  late final List<_P> points = [
    for (var i = 0; i < _nodes.length; i++)
      () {
        final y = 1 - 2 * (i + 0.5) / _nodes.length;
        final r = math.sqrt(1 - y * y);
        final theta = math.pi * (3 - math.sqrt(5)) * i;
        return _P(r * math.cos(theta), y, r * math.sin(theta));
      }(),
  ];

  // Each logo joined to its three nearest neighbours.
  late final List<(int, int)> links = () {
    final set = <(int, int)>{};
    for (var i = 0; i < points.length; i++) {
      final byDistance =
          [
            for (var j = 0; j < points.length; j++)
              if (j != i) j,
          ]..sort(
            (a, b) =>
                _d2(points[i], points[a]).compareTo(_d2(points[i], points[b])),
          );
      for (final j in byDistance.take(3)) {
        set.add(i < j ? (i, j) : (j, i));
      }
    }
    return set.toList();
  }();

  static double _d2(_P a, _P b) =>
      math.pow(a.x - b.x, 2) +
      math.pow(a.y - b.y, 2) +
      math.pow(a.z - b.z, 2).toDouble();

  @override
  void initState() {
    super.initState();
    ticker = createTicker((e) => time.value = e.inMicroseconds / 1e6)..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations && ticker.isActive) {
      ticker.stop();
    }
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.biggest;
        final small = size.width < Breakpoints.tablet;
        final wide = size.width >= Breakpoints.desktop;
        final radius = small
            ? size.width * 0.42
            : math.min(size.width, size.height) * 0.36;
        final centre = Offset(
          wide ? size.width * 0.66 : size.width / 2,
          // On phones it sits higher, behind the photo, so the headline below stays clear.
          small ? size.height * 0.26 : size.height * 0.52,
        );
        final logoSize = small ? 30.0 : 40.0;

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              time,
              widget.progress,
              widget.pointer,
            ]),
            builder: (context, _) {
              final t = time.value;
              final m = widget.pointer.value;
              final ry =
                  t * 0.12 + widget.progress.value * math.pi * 2 + m.dx * 0.35;
              final rx = -0.28 + m.dy * 0.22 + math.sin(t * 0.2) * 0.05;
              final focal = radius * 3.2;

              // Project every logo: z > 0 is towards the viewer.
              final projected = [
                for (final p in points)
                  () {
                    final r = p.rotate(rx, ry);
                    final scale = focal / (focal - r.z * radius);
                    return (
                      offset:
                          centre +
                          Offset(r.x * radius * scale, -r.y * radius * scale),
                      z: r.z,
                      scale: scale,
                    );
                  }(),
              ];
              final order = [for (var i = 0; i < projected.length; i++) i]
                ..sort((a, b) => projected[a].z.compareTo(projected[b].z));

              // Full strength at the top of the page, a quiet backdrop once the content begins.
              final strength =
                  (1 - widget.progress.value * 12).clamp(0.3, 1.0) *
                  (small ? 0.75 : 1.0);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GlobePainter(
                        strength: strength,
                        centre: centre,
                        radius: radius,
                        rx: rx,
                        ry: ry,
                        focal: focal,
                        time: t,
                        links: links,
                        projected: [for (final p in projected) (p.offset, p.z)],
                      ),
                    ),
                  ),
                  for (final i in order)
                    _Logo(
                      node: _nodes[i],
                      at: projected[i].offset,
                      size: logoSize * projected[i].scale,
                      // Front logos bright, back logos dim.
                      opacity:
                          (strength * (0.18 + 0.82 * (projected[i].z + 1) / 2))
                              .clamp(0.0, 1.0),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({
    required this.node,
    required this.at,
    required this.size,
    required this.opacity,
  });
  final _Node node;
  final Offset at;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final front = opacity > 0.7;
    final child = Container(
      width: node.icon == null ? null : size,
      height: size,
      padding: node.icon == null
          ? EdgeInsets.symmetric(horizontal: size * 0.32)
          : EdgeInsets.all(size * 0.22),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: front ? 0.6 : 0.25),
        ),
        boxShadow: front
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: size * 0.6,
                ),
              ]
            : null,
      ),
      child: node.icon != null
          ? BrandIcon(node.icon!, size: size * 0.56)
          : Text(
              node.label,
              style: body(
                size * 0.3,
                weight: FontWeight.w700,
                color: AppColors.primary,
                height: 1,
              ),
            ),
    );
    return Positioned(
      left: at.dx - (node.icon == null ? size * 1.1 : size / 2),
      top: at.dy - size / 2,
      child: Opacity(opacity: opacity, child: child),
    );
  }
}

class _GlobePainter extends CustomPainter {
  _GlobePainter({
    required this.strength,
    required this.centre,
    required this.radius,
    required this.rx,
    required this.ry,
    required this.focal,
    required this.time,
    required this.links,
    required this.projected,
  });

  final Offset centre;
  final double strength; // overall fade, 0..1
  final double radius, rx, ry, focal, time;
  final List<(int, int)> links;
  final List<(Offset, double)> projected;

  Offset _project(_P p) {
    final r = p.rotate(rx, ry);
    final s = focal / (focal - r.z * radius);
    return centre + Offset(r.x * radius * s, -r.y * radius * s);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Halo behind the globe.
    canvas.drawCircle(
      centre,
      radius * 1.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: (0.14) * strength),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: centre, radius: radius * 1.5)),
    );

    // Faint wireframe sphere: latitude and longitude lines.
    final wire = Paint()
      ..color = AppColors.primary.withValues(alpha: (0.07) * strength)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var lat = -60; lat <= 60; lat += 30) {
      final y = math.sin(lat * math.pi / 180),
          r = math.cos(lat * math.pi / 180);
      final path = Path();
      for (var a = 0; a <= 72; a++) {
        final th = a / 72 * 2 * math.pi;
        final o = _project(_P(r * math.cos(th), y, r * math.sin(th)));
        a == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, wire);
    }
    for (var lon = 0; lon < 180; lon += 30) {
      final phi = lon * math.pi / 180;
      final path = Path();
      for (var a = 0; a <= 72; a++) {
        final th = a / 72 * 2 * math.pi;
        final o = _project(
          _P(
            math.cos(th) * math.cos(phi),
            math.sin(th),
            math.cos(th) * math.sin(phi),
          ),
        );
        a == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, wire);
    }

    // Network links, brighter in front, with pulses of light travelling along some of them.
    for (var k = 0; k < links.length; k++) {
      final (a, b) = links[k];
      final (pa, za) = projected[a];
      final (pb, zb) = projected[b];
      final depth = ((za + zb) / 2 + 1) / 2; // 0 back .. 1 front
      canvas.drawLine(
        pa,
        pb,
        Paint()
          ..color = AppColors.primary.withValues(
            alpha: (0.06 + 0.3 * depth) * strength,
          )
          ..strokeWidth = 1 + depth * 0.6,
      );
      if (k % 3 == 0) {
        final f = (time * 0.35 + k * 0.137) % 1.0;
        final p = Offset.lerp(pa, pb, f)!;
        canvas.drawCircle(
          p,
          1.5 + depth * 1.8,
          Paint()
            ..color = AppColors.primary.withValues(
              alpha: (0.25 + 0.6 * depth) * strength,
            ),
        );
        canvas.drawCircle(
          p,
          6 + depth * 4,
          Paint()
            ..color = AppColors.primary.withValues(
              alpha: (0.08 * depth) * strength,
            )
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GlobePainter old) => true;
}

/// Faint, still star field behind the globe.
class StarField extends StatelessWidget {
  const StarField({super.key});

  @override
  Widget build(BuildContext context) => const RepaintBoundary(
    child: CustomPaint(painter: _StarPainter(), size: Size.infinite),
  );
}

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    final paint = Paint();
    for (var i = 0; i < 160; i++) {
      final o = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      paint.color = AppColors.primary.withValues(
        alpha: 0.08 + rnd.nextDouble() * 0.25,
      );
      canvas.drawCircle(o, 0.6 + rnd.nextDouble() * 1.1, paint);
    }
    void glow(Offset c, double r, double a) => canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: a),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    glow(Offset(size.width * 0.1, size.height * 0.85), size.width * 0.45, 0.06);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
