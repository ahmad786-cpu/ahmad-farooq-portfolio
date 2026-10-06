import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

Future<void> openUrl(String url) => launchUrl(
  Uri.parse(url),
  webOnlyWindowName: url.startsWith('mailto:') ? '_self' : '_blank',
);

/// Width-limited, padded wrapper used by every section.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.child,
    this.vertical = 100,
    this.color,
  });
  final Widget child;
  final double vertical;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Container(
      color: color,
      padding: EdgeInsets.symmetric(
        horizontal: narrow ? 20 : 32,
        vertical: narrow ? vertical * 0.6 : vertical,
      ),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.maxContent),
        child: child,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.badge,
    required this.title,
    this.subtitle,
  });
  final String? badge;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        children: [
          if (badge != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                badge!.toUpperCase(),
                style: body(
                  13,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ).copyWith(letterSpacing: 1.6),
              ),
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: display(w < Breakpoints.tablet ? 34 : 52),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: body(17),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (rect) => AppColors.gradient.createShader(rect),
    child: Text(text, style: style),
  );
}

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.solid = false});
  final String label;
  final bool solid;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: solid
          ? const Color(0xE6020617)
          : AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
    ),
    child: Text(
      label,
      style: body(
        12.5,
        weight: FontWeight.w600,
        color: AppColors.primary,
        height: 1.2,
      ),
    ),
  );
}

/// Pill button: filled gradient (primary) or glass outline.
class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
    this.compact = false,
  });
  final String label;
  final VoidCallback onTap;
  final Widget? icon;
  final bool primary;
  final bool compact;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, hover ? -3 : 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 18 : 28,
            vertical: widget.compact ? 11 : 15,
          ),
          decoration: BoxDecoration(
            gradient: p && !hover ? AppColors.gradient : null,
            color: p
                ? (hover ? Colors.white : null)
                : (hover
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.glass),
            borderRadius: BorderRadius.circular(999),
            border: p
                ? null
                : Border.all(
                    color: hover ? AppColors.primary : AppColors.border,
                  ),
            boxShadow: p
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: body(
                  15,
                  weight: FontWeight.w600,
                  color: p && hover ? AppColors.bg : AppColors.text,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card that lifts and glows on hover.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.radius,
  });
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? radius;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool hover = false;
  Offset local = Offset.zero; // pointer position inside the card
  Size size = Size.zero;

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.radius ??
        const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(32),
        );
    // Tilt towards the pointer: up to about 4 degrees on each axis.
    final fx = size.width == 0 ? 0.0 : local.dx / size.width - 0.5;
    final fy = size.height == 0 ? 0.0 : local.dy / size.height - 0.5;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..translateByDouble(0.0, hover ? -6.0 : 0.0, 0.0, 1.0)
      ..rotateX(hover ? -fy * 0.14 : 0)
      ..rotateY(hover ? fx * 0.14 : 0);
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      onHover: (e) => setState(() {
        local = e.localPosition;
        size = context.size ?? Size.zero;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: transform,
        transformAlignment: Alignment.center,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: hover
              ? AppColors.cardHover.withValues(alpha: 0.95)
              : AppColors.card.withValues(alpha: 0.9),
          borderRadius: radius,
          border: Border.all(
            color: hover ? AppColors.borderHover : AppColors.border,
          ),
          boxShadow: hover
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ]
              : null,
        ),
        // A soft light that follows the pointer across the card.
        foregroundDecoration: hover
            ? BoxDecoration(
                borderRadius: radius,
                gradient: RadialGradient(
                  center: Alignment(fx * 2, fy * 2),
                  radius: 0.9,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.13),
                    Colors.transparent,
                  ],
                ),
              )
            : null,
        child: HoverScope(hover: hover, child: widget.child),
      ),
    );
  }
}

/// Tells widgets inside a [HoverCard] whether the card is hovered (e.g. to zoom an image).
class HoverScope extends InheritedWidget {
  const HoverScope({super.key, required this.hover, required super.child});
  final bool hover;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HoverScope>()?.hover ?? false;

  @override
  bool updateShouldNotify(HoverScope old) => old.hover != hover;
}

/// Fades and slides its child in the first time it scrolls into view.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool shown = false;
  ScrollPosition? position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    position?.removeListener(check);
    position = Scrollable.maybeOf(context)?.position;
    position?.addListener(check);
    WidgetsBinding.instance.addPostFrameCallback((_) => check());
    // Check again once a page transition has finished moving this into place.
    Future.delayed(const Duration(milliseconds: 700), check);
  }

  void check() {
    if (shown || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.sizeOf(context).height * 0.92) {
      position?.removeListener(check);
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => shown = true);
      });
    }
  }

  @override
  void dispose() {
    position?.removeListener(check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: shown ? 1 : 0,
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeOut,
    child: AnimatedSlide(
      offset: shown ? Offset.zero : const Offset(0, 0.06),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}

/// Brand icon bundled in assets/icons (from Simple Icons), in its brand colour.
class BrandIcon extends StatelessWidget {
  const BrandIcon(this.slug, {super.key, this.size = 20, this.color});
  final String slug;
  final double size;
  final Color? color;

  // These brands' logos are black, which would vanish on the dark background.
  static const _darkLogos = {
    'anthropic',
    'nextdotjs',
    'express',
    'github',
    'vercel',
  };

  @override
  Widget build(BuildContext context) {
    final tint = color ?? (_darkLogos.contains(slug) ? AppColors.text : null);
    return SvgPicture.asset(
      'assets/icons/$slug.svg',
      width: size,
      height: size,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: slug,
    );
  }
}

/// Round social button (LinkedIn has no bundled logo, so it is drawn as text).
class SocialButton extends StatefulWidget {
  const SocialButton({
    super.key,
    required this.tooltip,
    required this.url,
    this.slug,
    this.text,
  });
  final String tooltip;
  final String url;
  final String? slug;
  final String? text;

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () => openUrl(widget.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          transform: Matrix4.translationValues(0, hover ? -3 : 0, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hover
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.glass,
            border: Border.all(
              color: hover ? AppColors.primary : AppColors.border,
            ),
          ),
          child: widget.slug != null
              ? BrandIcon(
                  widget.slug!,
                  size: 18,
                  color: hover ? AppColors.primary : AppColors.text,
                )
              : Text(
                  widget.text ?? '',
                  style: display(
                    16,
                    color: hover ? AppColors.primary : AppColors.text,
                    height: 1,
                  ),
                ),
        ),
      ),
    ),
  );
}

/// Draws the faint dotted grid and soft glows behind the whole page.
class BackdropPainter extends CustomPainter {
  const BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.035);
    for (double y = 2; y < size.height; y += 40) {
      for (double x = 2; x < size.width; x += 40) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
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
    glow(Offset(size.width * 0.85, size.height * 0.1), size.width * 0.45, 0.10);
    glow(Offset(size.width * 0.05, size.height * 0.75), size.width * 0.4, 0.07);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gradient text with a slow sweep of light moving through it.
class ShimmerText extends StatefulWidget {
  const ShimmerText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, child) => ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => LinearGradient(
        colors: const [
          AppColors.primary,
          AppColors.secondary,
          Color(0xFFBDEBFF),
          AppColors.primary,
          AppColors.secondary,
        ],
        stops: const [0, 0.35, 0.5, 0.65, 1],
        transform: _SlideGradient(c.value),
        tileMode: TileMode.mirror,
      ).createShader(rect),
      child: child,
    ),
    child: Text(widget.text, style: widget.style),
  );
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.t);
  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
}

/// Endless band of items scrolling sideways, fading out at both edges.
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.children,
    this.speed = 40,
    this.gap = 14,
  });
  final List<Widget> children;
  final double speed; // logical pixels per second
  final double gap;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  final scroll = ScrollController();
  late final Ticker ticker = createTicker(tick);

  @override
  void initState() {
    super.initState();
    ticker.start();
  }

  void tick(Duration elapsed) {
    if (!scroll.hasClients || !scroll.position.hasContentDimensions || scroll.position.maxScrollExtent <= 0) return;
    // The items are listed twice; wrap after one full copy so the loop is seamless.
    final copy =
        (scroll.position.maxScrollExtent + scroll.position.viewportDimension) /
        2;
    scroll.jumpTo((elapsed.inMicroseconds / 1e6 * widget.speed) % copy);
  }

  @override
  void dispose() {
    ticker.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (rect) => const LinearGradient(
      colors: [
        Colors.transparent,
        Colors.black,
        Colors.black,
        Colors.transparent,
      ],
      stops: [0, 0.08, 0.92, 1],
    ).createShader(rect),
    child: SingleChildScrollView(
      controller: scroll,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          for (var copy = 0; copy < 2; copy++)
            for (final child in widget.children)
              Padding(
                padding: EdgeInsets.only(right: widget.gap),
                child: child,
              ),
        ],
      ),
    ),
  );
}

/// A light that travels around the border of its child.
class GlowBorder extends StatefulWidget {
  const GlowBorder({super.key, required this.child, required this.radius});
  final Widget child;
  final double radius;

  @override
  State<GlowBorder> createState() => _GlowBorderState();
}

class _GlowBorderState extends State<GlowBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: c,
            builder: (context, _) => CustomPaint(
              painter: _SweepBorderPainter(
                c.value * 2 * math.pi,
                widget.radius,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _SweepBorderPainter extends CustomPainter {
  _SweepBorderPainter(this.angle, this.radius);
  final double angle;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(radius),
    );
    final shader = SweepGradient(
      colors: const [
        Colors.transparent,
        AppColors.primary,
        Colors.white,
        AppColors.secondary,
        Colors.transparent,
        Colors.transparent,
      ],
      stops: const [0, 0.08, 0.12, 0.18, 0.28, 1],
      transform: GradientRotation(angle),
    ).createShader(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(_SweepBorderPainter old) => old.angle != angle;
}
