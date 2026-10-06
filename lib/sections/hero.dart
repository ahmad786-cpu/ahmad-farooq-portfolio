import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../content.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.onChat, required this.onAskAi});
  final VoidCallback onChat;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= Breakpoints.desktop;
    final text = _HeroText(onChat: onChat, onAskAi: onAskAi, centered: !wide);
    final photo = _Photo(
      size: wide ? 440 : (w < Breakpoints.tablet ? 260 : 340),
    );
    return Section(
      vertical: 130,
      child: Column(
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: Reveal(child: text)),
                const SizedBox(width: 48),
                Expanded(
                  flex: 5,
                  child: Reveal(
                    delay: const Duration(milliseconds: 150),
                    child: Center(child: photo),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Reveal(child: photo),
                const SizedBox(height: 40),
                Reveal(delay: const Duration(milliseconds: 150), child: text),
              ],
            ),
          const SizedBox(height: 80),
          const Reveal(child: _Stats()),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.onChat,
    required this.onAskAi,
    required this.centered,
  });
  final VoidCallback onChat;
  final VoidCallback onAskAi;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final small = w < Breakpoints.tablet;
    final align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PulseDot(),
              const SizedBox(width: 10),
              Text(
                'Available for projects',
                style: body(
                  13,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'TOP-RATED AI & FULL-STACK DEVELOPER',
          textAlign: textAlign,
          style: body(
            small ? 14 : 17,
            weight: FontWeight.w600,
            color: AppColors.primary,
          ).copyWith(letterSpacing: 3),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Text(
              'Build Your Vision with ',
              textAlign: textAlign,
              style: display(small ? 38 : 58),
            ),
            ShimmerText('Ahmad Farooq', style: display(small ? 38 : 58)),
          ],
        ),
        const SizedBox(height: 18),
        _Typewriter(size: small ? 22 : 30, centered: centered),
        const SizedBox(height: 22),
        Text(
          '“Crafting seamless experiences through code and design.”',
          textAlign: textAlign,
          style: body(
            17,
            color: AppColors.dim,
          ).copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'With 5+ years of experience, I build AI assistants, voice agents and fast, reliable apps, helping businesses turn ideas into products people actually use, from first conversation to launch and beyond.',
            textAlign: textAlign,
            style: body(16.5),
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          children: const [
            SocialButton(tooltip: 'LinkedIn', url: Links.linkedin, text: 'in'),
            SocialButton(tooltip: 'GitHub', url: Links.github, slug: 'github'),
            SocialButton(tooltip: 'Fiverr', url: Links.fiverr, slug: 'fiverr'),
            SocialButton(
              tooltip: 'WhatsApp',
              url: Links.whatsapp,
              slug: 'whatsapp',
            ),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            PillButton(label: "Let's Chat", primary: true, onTap: onChat),
            PillButton(
              label: 'Talk to my AI',
              icon: const Icon(
                Icons.mic_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              onTap: onAskAi,
            ),
          ],
        ),
      ],
    );
  }
}

/// Types each role, pauses, deletes it, and moves to the next (like the HTML site).
class _Typewriter extends StatefulWidget {
  const _Typewriter({required this.size, required this.centered});
  final double size;
  final bool centered;

  @override
  State<_Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<_Typewriter> {
  int role = 0;
  int chars = 0;
  bool deleting = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    tick();
  }

  void tick() {
    final text = roles[role];
    final Duration next;
    if (!deleting && chars < text.length) {
      chars++;
      next = const Duration(milliseconds: 70);
    } else if (!deleting) {
      deleting = true;
      next = const Duration(milliseconds: 1600);
    } else if (chars > 0) {
      chars--;
      next = const Duration(milliseconds: 35);
    } else {
      deleting = false;
      role = (role + 1) % roles.length;
      next = const Duration(milliseconds: 300);
    }
    if (mounted) setState(() {});
    timer = Timer(next, tick);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'I am ${roles.first}',
    child: ExcludeSemantics(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'I am ',
              style: display(
                widget.size,
                weight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            TextSpan(
              text: roles[role].substring(0, chars),
              style: display(
                widget.size,
                weight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            TextSpan(
              text: '|',
              style: display(
                widget.size,
                weight: FontWeight.w300,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        textAlign: widget.centered ? TextAlign.center : TextAlign.start,
      ),
    ),
  );
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 10,
    height: 10,
    child: AnimatedBuilder(
      animation: c,
      builder: (context, _) => Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 1 + c.value * 1.6,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF4ADE80,
                ).withValues(alpha: 0.5 * (1 - c.value)),
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4ADE80),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Photo extends StatelessWidget {
  const _Photo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 18,
          top: 18,
          right: -18,
          bottom: -18,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 60,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                'assets/images/profile.webp',
                fit: BoxFit.cover,
                semanticLabel: 'Ahmad Farooq, AI and full-stack developer',
              ),
            ),
          ),
        ),
        // Floating badges that bob gently around the photo.
        _FloatingBadge(
          left: -size * 0.12,
          top: size * 0.08,
          icon: Icons.rocket_launch_rounded,
          label: '50+ Projects',
          phase: 0,
        ),
        _FloatingBadge(
          right: -size * 0.1,
          top: size * 0.46,
          icon: Icons.star_rounded,
          label: '100% Satisfaction',
          phase: 1.3,
        ),
        _FloatingBadge(
          left: -size * 0.08,
          bottom: size * 0.06,
          icon: Icons.graphic_eq_rounded,
          label: 'AI & Voice Agents',
          phase: 2.6,
        ),
      ],
    ),
  );
}

class _FloatingBadge extends StatefulWidget {
  const _FloatingBadge({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.icon,
    required this.label,
    required this.phase,
  });
  final double? left, right, top, bottom;
  final IconData icon;
  final String label;
  final double phase; // so the badges do not move in step

  @override
  State<_FloatingBadge> createState() => _FloatingBadgeState();
}

class _FloatingBadgeState extends State<_FloatingBadge>
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
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Positioned(
      left: widget.left,
      right: widget.right,
      top: widget.top,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: c,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, math.sin(c.value * 2 * math.pi + widget.phase) * 8),
          child: child,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: small ? 10 : 14,
            vertical: small ? 7 : 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderHover),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: small ? 13 : 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: body(
                  small ? 11.5 : 13.5,
                  weight: FontWeight.w700,
                  color: AppColors.text,
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

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 36, horizontal: small ? 16 : 32),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 28,
        children: [
          for (final s in heroStats)
            SizedBox(
              width: small ? 140 : 220,
              child: CountUpStat(stat: s),
            ),
        ],
      ),
    );
  }
}

/// A stat that counts up from zero when the page loads.
class CountUpStat extends StatelessWidget {
  const CountUpStat({super.key, required this.stat});
  final Stat stat;

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: stat.value.toDouble()),
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) {
            final n = v.round();
            final shown = n >= 1000
                ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}'
                : '$n';
            return GradientText(
              '$shown${stat.suffix}',
              style: display(small ? 34 : 44),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: body(14, color: AppColors.dim, height: 1.3),
        ),
      ],
    );
  }
}
