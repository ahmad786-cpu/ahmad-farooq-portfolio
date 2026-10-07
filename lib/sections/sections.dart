import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../content.dart';
import '../content_more.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'features.dart' show ContactForm, TestimonialCarousel;
import 'hero.dart' show CountUpStat;

/// Lays children out in [columns] equal columns that wrap, with consistent gaps.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.children,
    this.gap = 24,
  });
  final int columns;
  final List<Widget> children;
  final double gap;

  // Cards are laid out row by row, and every card in a row is stretched to the tallest one,
  // so rows line up instead of each card being only as tall as its own text.
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += columns) {
        final row = children.sublist(i, math.min(i + columns, children.length));
        if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
        rows.add(
          columns == 1
              ? row.first
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var j = 0; j < columns; j++) ...[
                        if (j > 0) SizedBox(width: gap),
                        Expanded(
                          child: j < row.length ? row[j] : const SizedBox(),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    },
  );
}

int columnsFor(double width, {int desktop = 3, int tablet = 2}) =>
    width >= Breakpoints.desktop
    ? desktop
    : (width >= Breakpoints.tablet ? tablet : 1);

// --- Services ------------------------------------------------------------------------------

class SolutionsSection extends StatelessWidget {
  const SolutionsSection({super.key});

  static const icons = {
    'ai': Icons.auto_awesome_rounded,
    'arch': Icons.hub_rounded,
    'mobile': Icons.phone_iphone_rounded,
    'design': Icons.palette_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Section(
      child: Column(
        children: [
          const Reveal(
            child: SectionHeader(
              badge: 'Expert Services',
              title: 'Premium Development Solutions',
              subtitle:
                  'I bridge the gap between complex engineering and user-centric design.',
            ),
          ),
          ResponsiveGrid(
            columns: columnsFor(w, desktop: 2),
            children: [
              for (final (i, s) in solutions.indexed)
                Reveal(
                  delay: Duration(milliseconds: 100 * i),
                  child: HoverCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icons[s.icon],
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(s.title, style: display(24)),
                        const SizedBox(height: 10),
                        Text(s.text, style: body(15.5)),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [for (final p in s.points) Tag(p)],
                        ),
                      ],
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

// --- About ---------------------------------------------------------------------------------

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= Breakpoints.desktop;
    final small = w < Breakpoints.tablet;
    final text = Column(
      crossAxisAlignment: wide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          'ABOUT ME',
          style: body(
            13,
            weight: FontWeight.w700,
            color: AppColors.primary,
          ).copyWith(letterSpacing: 1.6),
        ),
        const SizedBox(height: 12),
        Text(
          'From complex code to',
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: display(small ? 32 : 46),
        ),
        GradientText('elegant products', style: display(small ? 32 : 46)),
        const SizedBox(height: 20),
        Text(
          'I build AI products, web platforms and mobile apps grounded in real user behaviour: simple, intuitive experiences that drive measurable growth for the businesses behind them.',
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: body(16.5),
        ),
        const SizedBox(height: 14),
        Text(
          "Beyond client work, I lead local tech communities, sharing what I've learned and helping new developers land their first roles.",
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: body(16.5),
        ),
        const SizedBox(height: 28),
        PillButton(
          label: 'Download Resume',
          primary: true,
          icon: const Icon(
            Icons.download_rounded,
            size: 18,
            color: Colors.white,
          ),
          onTap: () => openUrl(Links.resume),
        ),
      ],
    );
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Image.asset(
          'assets/images/profile.webp',
          fit: BoxFit.cover,
          semanticLabel: 'Ahmad Farooq',
        ),
      ),
    );
    return Section(
      child: wide
          ? Row(
              children: [
                Expanded(child: Reveal(child: text)),
                const SizedBox(width: 64),
                SizedBox(
                  width: 400,
                  child: Reveal(
                    delay: const Duration(milliseconds: 150),
                    child: photo,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Reveal(child: text),
                const SizedBox(height: 40),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Reveal(child: photo),
                ),
              ],
            ),
    );
  }
}

// --- Tech stack -----------------------------------------------------------------------------

class TechSection extends StatelessWidget {
  const TechSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Section(
      child: Column(
        children: [
          const Reveal(
            child: SectionHeader(
              title: 'Tech Stack',
              subtitle:
                  'Change is inevitable, so I keep exploring new tech, learn it fast, and build something real out of it.',
            ),
          ),
          ResponsiveGrid(
            columns: columnsFor(w),
            gap: 20,
            children: [
              for (final (i, cat) in techStack.indexed)
                Reveal(
                  delay: Duration(milliseconds: 80 * i),
                  child: HoverCard(
                    padding: const EdgeInsets.all(24),
                    radius: BorderRadius.circular(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BrandIcon(cat.icon, size: 26),
                            const SizedBox(width: 12),
                            Text(cat.title, style: display(20)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [for (final t in cat.items) _TechPill(t)],
                        ),
                      ],
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

class _TechPill extends StatelessWidget {
  const _TechPill(this.item);
  final TechItem item;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          BrandIcon(item.icon!, size: 15),
          const SizedBox(width: 7),
        ],
        Text(
          item.name,
          style: body(
            13.5,
            weight: FontWeight.w500,
            color: AppColors.text,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}

// --- Projects -------------------------------------------------------------------------------

// --- Experience -----------------------------------------------------------------------------

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Section(
      child: Column(
        children: [
          const Reveal(
            child: SectionHeader(
              title: 'Professional Journey',
              subtitle: 'A clear roadmap of my work and growth.',
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              children: [
                for (final (i, job) in jobs.indexed)
                  Reveal(
                    delay: Duration(milliseconds: 80 * i),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: small ? 24 : 40,
                            child: Column(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(top: 28),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.gradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < jobs.length - 1)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: small ? 12 : 20),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: HoverCard(
                                radius: BorderRadius.circular(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.period,
                                      style: body(
                                        14,
                                        weight: FontWeight.w700,
                                        color: AppColors.primary,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      job.title,
                                      style: display(small ? 22 : 26),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      job.place,
                                      style: body(14.5, color: AppColors.dim),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(job.summary, style: body(15.5)),
                                    for (final point in job.points)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 9,
                                                right: 10,
                                              ),
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                point,
                                                style: body(15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final t in job.tags) Tag(t),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Community and testimonials ---------------------------------------------------------------

class CommunitySection extends StatelessWidget {
  const CommunitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final small = w < Breakpoints.tablet;
    return Section(
      child: Column(
        children: [
          Reveal(
            child: Text(
              '"If you want to go fast, go alone. If you want to go far, go together"',
              textAlign: TextAlign.center,
              style: body(
                small ? 17 : 20,
                color: AppColors.dim,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),
          Reveal(
            child: Text(
              'Community Impact',
              textAlign: TextAlign.center,
              style: display(small ? 32 : 46),
            ),
          ),
          const SizedBox(height: 36),
          Reveal(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 24,
              children: [
                for (final s in communityStats)
                  SizedBox(
                    width: small ? 150 : 240,
                    child: HoverCard(
                      radius: BorderRadius.circular(22),
                      child: CountUpStat(stat: s),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 90),
          const Reveal(
            child: SectionHeader(
              badge: 'Social Proof',
              title: 'What Clients Say',
              subtitle: 'Trusted by tech leaders and founders worldwide.',
            ),
          ),
          const Reveal(child: Center(child: TestimonialCarousel())),
        ],
      ),
    );
  }
}

// --- Contact ---------------------------------------------------------------------------------

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Section(
      child: Reveal(
        // A light travels around the card's border.
        child: GlowBorder(
          radius: 32,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: small ? 44 : 64,
              horizontal: small ? 20 : 48,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.borderHover),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.card.withValues(alpha: 0.9),
                  AppColors.bg.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Get in touch',
                  textAlign: TextAlign.center,
                  style: display(small ? 36 : 54),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tell me about your project. I usually reply within a day.",
                  textAlign: TextAlign.center,
                  style: body(18),
                ),
                const SizedBox(height: 32),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: const ContactForm(),
                ),
                const SizedBox(height: 30),
                Text('Prefer to talk?', style: body(15, color: AppColors.dim)),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    PillButton(
                      label: 'Book a call',
                      primary: true,
                      icon: const Icon(
                        Icons.event_available_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      onTap: () => openUrl(
                        bookCallUrl.isNotEmpty
                            ? bookCallUrl
                            : '${Links.whatsapp}?text=${Uri.encodeComponent('Hi Ahmad, I would like to book a short call about my project. When are you free?')}',
                      ),
                    ),
                    PillButton(
                      label: "Let's chat on WhatsApp",
                      icon: const BrandIcon('whatsapp', size: 18),
                      onTap: () => openUrl(Links.whatsapp),
                    ),
                    PillButton(
                      label: 'Hire me on Fiverr',
                      icon: const BrandIcon('fiverr', size: 18),
                      onTap: () => openUrl(Links.fiverr),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text('Or email me at', style: body(15, color: AppColors.dim)),
                const SizedBox(height: 4),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => openUrl('mailto:${Links.email}'),
                    child: Text(
                      Links.email,
                      style: display(small ? 18 : 22, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- FAQ -------------------------------------------------------------------------------------

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int open = 0;

  @override
  Widget build(BuildContext context) => Section(
    child: Column(
      children: [
        const Reveal(
          child: SectionHeader(
            badge: 'FAQ',
            title: 'Common Questions',
            subtitle: 'Quick answers to the most frequent inquiries.',
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              for (final (i, f) in faqs.indexed)
                Reveal(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: AppColors.card.withValues(
                          alpha: open == i ? 0.75 : 0.45,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: open == i
                              ? AppColors.borderHover
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () =>
                                setState(() => open = open == i ? -1 : i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      f.question,
                                      style: display(
                                        18,
                                        weight: FontWeight.w600,
                                        color: open == i
                                            ? AppColors.primary
                                            : AppColors.text,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: open == i ? 0.125 : 0,
                                    duration: const Duration(milliseconds: 250),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            child: open == i
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      0,
                                      24,
                                      22,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(f.answer, style: body(15.5)),
                                    ),
                                  )
                                : const SizedBox(width: double.infinity),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

// --- Footer ----------------------------------------------------------------------------------

class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.onNavigate});
  final void Function(String id) onNavigate;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.webp',
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(width: 10),
            GradientText('AF', style: display(24)),
            Text(' TECH', style: display(24)),
          ],
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Text(
            'Building modern digital experiences with focus on performance, scalability, and user-centric design.',
            style: body(14.5, color: AppColors.dim),
          ),
        ),
        const SizedBox(height: 18),
        const Wrap(
          spacing: 10,
          children: [
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
      ],
    );
    Widget column(String title, List<Widget> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: display(17)),
        const SizedBox(height: 14),
        ...items,
      ],
    );
    Widget link(String label, String id) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onNavigate(id),
          child: Text(
            label,
            style: body(14.5, color: AppColors.dim, height: 1.3),
          ),
        ),
      ),
    );
    final nav = column('Navigation', [
      link('Home', 'home'),
      link('About Me', 'about'),
      link('Projects', 'projects'),
      link('Experience', 'experience'),
      link('Ask My AI', 'ask-my-ai'),
    ]);
    final status = column('Status', [
      Text(
        'Pakistan Standard Time',
        style: body(14.5, color: AppColors.dim, height: 1.3),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4ADE80),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Available for new projects',
            style: body(14.5, color: AppColors.text, height: 1.3),
          ),
        ],
      ),
    ]);
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Section(
        vertical: 60,
        child: Column(
          children: [
            if (w >= Breakpoints.tablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: brand),
                  Expanded(child: nav),
                  Expanded(child: status),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  brand,
                  const SizedBox(height: 32),
                  nav,
                  const SizedBox(height: 18),
                  status,
                ],
              ),
            const SizedBox(height: 40),
            const Divider(color: AppColors.border),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              spacing: 24,
              children: [
                Text(
                  '© ${DateTime.now().year} AF TECH. All rights reserved.',
                  style: body(13.5, color: AppColors.dim),
                ),
                Text(
                  'Designed & built with Flutter by Ahmad Farooq',
                  style: body(13.5, color: AppColors.dim),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fills the remaining height of a card when the card is stretched to its row's height
/// (wider screens), and simply wraps its content when it is not (single column on phones).
/// Endless strip of the tech stack, between the hero and the services.
class TechStrip extends StatelessWidget {
  const TechStrip({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Text(
          'TOOLS I SHIP WITH',
          style: body(
            12.5,
            weight: FontWeight.w700,
            color: AppColors.dim,
          ).copyWith(letterSpacing: 2.4),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: Marquee(
            children: [
              for (final cat in techStack)
                for (final t in cat.items)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (t.icon != null) ...[
                          BrandIcon(t.icon!, size: 18),
                          const SizedBox(width: 9),
                        ],
                        Text(
                          t.name,
                          style: body(
                            14.5,
                            weight: FontWeight.w600,
                            color: AppColors.text,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    ),
  );
}
