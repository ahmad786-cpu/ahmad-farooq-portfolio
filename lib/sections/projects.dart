import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_state.dart';
import '../content.dart';
import '../content_more.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'sections.dart' show ResponsiveGrid, columnsFor;

/// Filter tabs, and which tabs each project appears under (the first one is its label).
const projectFilters = ['All', 'AI & Automation', 'Mobile Apps', 'Web & SaaS', 'E-commerce'];

const _categories = {
  'Parlor': ['AI & Automation', 'Web & SaaS'],
  'Enterprise CRM System': ['Web & SaaS', 'AI & Automation'],
  'AI Legal Slack Organization': ['AI & Automation', 'Web & SaaS'],
  'Zyro Cloud': ['E-commerce', 'AI & Automation', 'Web & SaaS'],
  'BuddyCart.pk': ['E-commerce', 'Web & SaaS'],
  'RouteBuddy': ['Mobile Apps', 'AI & Automation'],
  'SkillBuddy': ['Mobile Apps', 'E-commerce'],
  'Flappy Dash Game': ['Mobile Apps'],
  'Dukan e Khata': ['Mobile Apps'],
  'HomeHaven Marketplace': ['Mobile Apps', 'E-commerce'],
  'Titan VPN': ['Mobile Apps'],
  'Kardly Branding': ['Mobile Apps', 'AI & Automation'],
  'Shortify AI Tool': ['AI & Automation', 'Mobile Apps'],
};

List<String> categoriesOf(Project p) => _categories[p.title] ?? const ['Mobile Apps'];

IconData _iconFor(String category) => switch (category) {
  'AI & Automation' => Icons.auto_awesome_rounded,
  'Mobile Apps' => Icons.phone_iphone_rounded,
  'Web & SaaS' => Icons.language_rounded,
  'E-commerce' => Icons.shopping_bag_rounded,
  _ => Icons.apps_rounded,
};

Widget _imageOf(Project p) => p.image.endsWith('.svg')
    ? SvgPicture.asset('assets/images/${p.image}', fit: BoxFit.cover, semanticsLabel: p.title)
    : Image.asset('assets/images/${p.image}', fit: BoxFit.cover, semanticLabel: p.title);

/// What clicking a project's picture does: its case study if it has one, otherwise its first link.
VoidCallback? _primaryAction(Project p, VoidCallback onAskAi) {
  final study = caseStudyFor(p.title);
  if (study != null) return () => AppState.openCaseStudy(study.slug);
  if (p.links.isEmpty) return null;
  final link = p.links.first;
  return link.kind == LinkKind.internal ? onAskAi : () => openUrl(link.url);
}

String? _primaryLabel(Project p) {
  if (caseStudyFor(p.title) != null) return 'Read the case study';
  if (p.links.isEmpty) return null;
  return p.links.first.kind == LinkKind.store ? 'Get the app' : 'Open project';
}

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key, required this.onAskAi});
  final VoidCallback onAskAi;

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String filter = 'All';
  bool expanded = false;

  static const _collapsedCount = 6; // cards under the spotlight before "Show all"

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = columnsFor(w, desktop: 3);
    final showSpotlight = filter == 'All';
    final list = [
      for (final p in projects)
        if (filter == 'All' || categoriesOf(p).contains(filter)) p,
    ];
    final spotlight = showSpotlight ? list.first : null;
    var rest = showSpotlight ? list.skip(1).toList() : list;
    final hidden = showSpotlight && !expanded ? math.max(0, rest.length - _collapsedCount) : 0;
    if (hidden > 0) rest = rest.take(_collapsedCount).toList();

    return Section(
      child: Column(
        children: [
          const Reveal(
            child: SectionHeader(
              badge: 'Portfolio',
              title: 'Featured Work',
              subtitle: 'AI products, mobile apps and platforms I have designed, built and shipped for clients and for myself.',
            ),
          ),
          Reveal(child: _Filters(selected: filter, onSelect: (f) => setState(() => (filter = f, expanded = false)))),
          const SizedBox(height: 36),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(a), child: child),
            ),
            child: Column(
              key: ValueKey('$filter-$expanded'),
              children: [
                if (spotlight != null) ...[
                  Reveal(child: _Spotlight(project: spotlight, onAskAi: widget.onAskAi)),
                  const SizedBox(height: 28),
                ],
                ResponsiveGrid(
                  columns: cols,
                  children: [
                    for (final (i, p) in rest.indexed)
                      Reveal(
                        delay: Duration(milliseconds: 80 * (i % cols)),
                        child: _ProjectCard(
                          project: p,
                          number: projects.indexOf(p) + 1,
                          stretch: cols > 1,
                          onAskAi: widget.onAskAi,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: [
              if (hidden > 0)
                PillButton(
                  label: 'Show all projects (+$hidden)',
                  primary: true,
                  icon: const Icon(Icons.expand_more_rounded, size: 20, color: Colors.white),
                  onTap: () => setState(() => expanded = true),
                ),
              PillButton(
                label: 'More on GitHub',
                primary: hidden == 0,
                icon: BrandIcon('github', size: 18, color: hidden == 0 ? Colors.white : AppColors.text),
                onTap: () => openUrl(Links.github),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Filter tabs ---------------------------------------------------------------------------------

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    int count(String f) => f == 'All' ? projects.length : projects.where((p) => categoriesOf(p).contains(f)).length;
    final chips = [
      for (final f in projectFilters)
        _FilterChip(label: f, count: count(f), icon: _iconFor(f), selected: f == selected, onTap: () => onSelect(f)),
    ];
    // Phones: one row you can swipe sideways, instead of a tall stack of chips.
    if (MediaQuery.sizeOf(context).width < Breakpoints.tablet) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          for (final (i, c) in chips.indexed) ...[if (i > 0) const SizedBox(width: 8), c],
        ]),
      );
    }
    return Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10, children: chips);
  }
}

class _FilterChip extends StatefulWidget {
  const _FilterChip({required this.label, required this.count, required this.icon, required this.selected, required this.onTap});
  final String label;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          decoration: BoxDecoration(
            gradient: on ? AppColors.gradient : null,
            color: on ? null : (hover ? AppColors.cardHover : AppColors.card.withValues(alpha: 0.85)),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? Colors.transparent : (hover ? AppColors.borderHover : AppColors.border)),
            boxShadow: on ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 6))] : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 17, color: on ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Text(widget.label, style: body(14.5, weight: FontWeight.w600, color: on ? Colors.white : AppColors.text, height: 1.2)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: on ? Colors.white.withValues(alpha: 0.22) : AppColors.bg.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('${widget.count}', style: body(12.5, weight: FontWeight.w700, color: on ? Colors.white : AppColors.muted, height: 1.3)),
            ),
          ]),
        ),
      ),
    );
  }
}

// --- Spotlight (first project, large) ------------------------------------------------------------

class _Spotlight extends StatelessWidget {
  const _Spotlight({required this.project, required this.onAskAi});
  final Project project;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.tablet + 140;
    final picture = _Picture(project: p, number: 1, onAskAi: onAskAi, big: true);
    final details = Padding(
      padding: EdgeInsets.all(wide ? 40 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
              const SizedBox(width: 6),
              Text('FEATURED PROJECT', style: body(12, weight: FontWeight.w700, color: AppColors.primary, height: 1.2).copyWith(letterSpacing: 1.4)),
            ]),
          ),
          const SizedBox(height: 18),
          ShimmerText(p.title, style: display(wide ? 46 : 34)),
          const SizedBox(height: 14),
          Text(p.description, style: body(wide ? 16.5 : 15.5, color: AppColors.text.withValues(alpha: 0.85))),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final t in p.tags) Tag(t)]),
          const SizedBox(height: 26),
          _Buttons(project: p, onAskAi: onAskAi, compact: false),
        ],
      ),
    );
    return GlowBorder(
      radius: 32,
      child: HoverCard(
        padding: EdgeInsets.zero,
        radius: BorderRadius.circular(32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: wide
              ? IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(flex: 11, child: _FillHeight(minHeight: 400, child: picture)),
                    Expanded(flex: 10, child: details),
                  ]),
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  AspectRatio(aspectRatio: 3 / 2, child: picture),
                  details,
                ]),
        ),
      ),
    );
  }
}

// --- Regular card ---------------------------------------------------------------------------------

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.number, required this.stretch, required this.onAskAi});
  final Project project;
  final int number;
  final bool stretch; // true when the card sits in a row and should fill its height
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.title, style: display(22)),
          const SizedBox(height: 10),
          Text(p.description, style: body(14.5)),
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final t in p.tags) Tag(t)]),
          if (stretch) const Spacer(),
          if (p.links.isNotEmpty || caseStudyFor(p.title) != null) ...[
            const SizedBox(height: 18),
            _Buttons(project: p, onAskAi: onAskAi, compact: true),
          ],
        ],
      ),
    );
    return HoverCard(
      padding: EdgeInsets.zero,
      radius: BorderRadius.circular(28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(aspectRatio: 16 / 10, child: _Picture(project: p, number: number, onAskAi: onAskAi)),
            if (stretch) Expanded(child: content) else content,
          ],
        ),
      ),
    );
  }
}

/// Project picture: zooms on hover, with its number, its category, and a "view" overlay.
class _Picture extends StatelessWidget {
  const _Picture({required this.project, required this.number, required this.onAskAi, this.big = false});
  final Project project;
  final int number;
  final VoidCallback onAskAi;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final hover = HoverScope.of(context);
    final action = _primaryAction(p, onAskAi);
    final label = _primaryLabel(p);
    final category = categoriesOf(p).first;
    Widget glass(Widget child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: child,
        );
    return MouseRegion(
      cursor: action != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: action,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScale(
              scale: hover ? 1.08 : 1,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              child: _imageOf(p),
            ),
            // Soft fade into the card at the bottom.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment(0, 0.2),
                  colors: [Color(0xCC020617), Colors.transparent],
                ),
              ),
            ),
            // Hover overlay with the main action.
            if (label != null)
              AnimatedOpacity(
                opacity: hover ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: AppColors.bg.withValues(alpha: 0.55),
                  alignment: Alignment.center,
                  child: AnimatedSlide(
                    offset: hover ? Offset.zero : const Offset(0, 0.4),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.6), blurRadius: 24)],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(label, style: body(15, weight: FontWeight.w700, color: Colors.white, height: 1.2)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ]),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 14,
              top: 14,
              child: glass(Text(number.toString().padLeft(2, '0'),
                  style: display(big ? 16 : 14, color: Colors.white, height: 1.2).copyWith(fontFeatures: const [FontFeature.tabularFigures()]))),
            ),
            Positioned(
              right: 14,
              top: 14,
              child: glass(Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_iconFor(category), size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(category, style: body(12.5, weight: FontWeight.w600, color: Colors.white, height: 1.2)),
              ])),
            ),
          ],
        ),
      ),
    );
  }
}

/// Case study button plus the project's own links.
class _Buttons extends StatelessWidget {
  const _Buttons({required this.project, required this.onAskAi, required this.compact});
  final Project project;
  final VoidCallback onAskAi;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final study = caseStudyFor(p.title);
    final size = compact ? 16.0 : 18.0;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (i, link) in p.links.indexed)
          PillButton(
            compact: compact,
            primary: i == p.links.length - 1,
            label: link.label,
            icon: switch (link.kind) {
              LinkKind.github => BrandIcon('github', size: size, color: i == p.links.length - 1 ? Colors.white : AppColors.text),
              LinkKind.internal => Icon(Icons.mic_rounded, size: size, color: i == p.links.length - 1 ? Colors.white : AppColors.text),
              LinkKind.store => Icon(Icons.shop_rounded, size: size, color: i == p.links.length - 1 ? Colors.white : AppColors.text),
              LinkKind.web => Icon(Icons.open_in_new_rounded, size: size, color: i == p.links.length - 1 ? Colors.white : AppColors.text),
            },
            onTap: () => link.kind == LinkKind.internal ? onAskAi() : openUrl(link.url),
          ),
        if (study != null)
          PillButton(
            compact: compact,
            primary: p.links.isEmpty,
            label: 'Case study',
            icon: Icon(Icons.article_rounded, size: size, color: p.links.isEmpty ? Colors.white : AppColors.text),
            onTap: () => AppState.openCaseStudy(study.slug),
          ),
      ],
    );
  }
}

/// Takes whatever height its row gives it (at least [minHeight]) and reports only [minHeight] as
/// its natural height, so the row's height comes from the text beside it, not the image file.
class _FillHeight extends SingleChildRenderObjectWidget {
  const _FillHeight({required this.minHeight, super.child});
  final double minHeight;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFillHeight(minHeight);

  @override
  void updateRenderObject(BuildContext context, _RenderFillHeight renderObject) => renderObject.minHeight = minHeight;
}

class _RenderFillHeight extends RenderProxyBox {
  _RenderFillHeight(this.minHeight);
  double minHeight;

  @override
  double computeMinIntrinsicHeight(double width) => minHeight;
  @override
  double computeMaxIntrinsicHeight(double width) => minHeight;

  @override
  void performLayout() {
    final c = constraints;
    final h = c.hasBoundedHeight ? math.max(c.maxHeight, minHeight) : minHeight;
    child!.layout(BoxConstraints.tight(Size(c.maxWidth, h)), parentUsesSize: true);
    size = c.constrain(child!.size);
  }
}
