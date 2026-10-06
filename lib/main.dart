import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'content_more.dart';
import 'pages/case_study.dart';
import 'sections/ask_ai.dart';
import 'sections/features.dart';
import 'sections/hero.dart';
import 'sections/sections.dart';
import 'theme.dart';
import 'widgets/ai_fab.dart';
import 'widgets/command_palette.dart';
import 'widgets/common.dart';
import 'widgets/tech_globe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ctrl+K (Cmd+K on Mac) opens the command palette from anywhere on the site.
  HardwareKeyboard.instance.addHandler((event) {
    final k = HardwareKeyboard.instance;
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyK &&
        (k.isControlPressed || k.isMetaPressed)) {
      AppState.paletteOpen.value = !AppState.paletteOpen.value;
      return true;
    }
    return false;
  });
  runApp(const PortfolioApp());
}

/// Layer above every page: the floating AI button and panel, and the command palette. It has
/// its own Overlay so text fields and tooltips inside it work.
final _globalLayer = OverlayEntry(
  builder: (context) => const Material(
    type: MaterialType.transparency,
    child: Stack(
      children: [
        Positioned(right: 20, bottom: 20, child: AiFab()),
        CommandPalette(),
      ],
    ),
  ),
);

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Ahmad Farooq | AI & Full-Stack Developer',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    navigatorKey: AppState.navigatorKey,
    // Case studies live at /#/work/<slug>; everything else is the home page.
    onGenerateRoute: (settings) {
      final name = settings.name ?? '/';
      if (name.startsWith('/work/')) {
        final slug = name.substring('/work/'.length);
        for (final study in caseStudies) {
          if (study.slug == slug) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => CaseStudyPage(study: study),
            );
          }
        }
      }
      if (name != '/') return null;
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const HomePage(),
      );
    },
    onUnknownRoute: (settings) => MaterialPageRoute(
      settings: const RouteSettings(name: '/'),
      builder: (_) => const HomePage(),
    ),
    builder: (context, child) => Stack(
      children: [
        ?child,
        Positioned.fill(child: Overlay(initialEntries: [_globalLayer])),
      ],
    ),
  );
}

class NavItem {
  const NavItem(this.id, this.label);
  final String id;
  final String label;
}

const navItems = [
  NavItem('home', 'Home'),
  NavItem('about', 'About'),
  NavItem('tech', 'Tech'),
  NavItem('projects', 'Projects'),
  NavItem('experience', 'Experience'),
  NavItem('ask-my-ai', 'Ask My AI'),
  NavItem('contact', 'Contact'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scroll = ScrollController();
  final keys = {
    for (final id in [
      'home',
      'solutions',
      'about',
      'tech',
      'projects',
      'process',
      'experience',
      'community',
      'ask-my-ai',
      'estimate',
      'contact',
      'faq',
    ])
      id: GlobalKey(),
  };
  String active = 'home';
  bool showTop = false;
  // Drive the 3D background: which section is in view, and where the mouse is.
  final sceneProgress = ValueNotifier<double>(0);
  final pointer = ValueNotifier<Offset>(Offset.zero);
  final cursor = ValueNotifier<Offset?>(null);

  @override
  void initState() {
    super.initState();
    scroll.addListener(onScroll);
    AppState.scrollTo = goTo;
  }

  @override
  void dispose() {
    scroll.dispose();
    sceneProgress.dispose();
    pointer.dispose();
    cursor.dispose();
    super.dispose();
  }

  // Highlights the nav item for the section currently under the nav bar.
  void onScroll() {
    String current = 'home';
    for (final item in navItems) {
      final box =
          keys[item.id]?.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.localToGlobal(Offset.zero).dy <= 140) {
        current = item.id;
      }
    }
    final top = scroll.offset > 600;
    if (current != active || top != showTop) {
      setState(() => (active = current, showTop = top));
    }
    updateSceneProgress();
  }

  // Sections differ a lot in height, so the 3D camera follows which section fills the middle of
  // the screen (and how far through it we are), not the raw scroll distance.
  void updateSceneProgress() {
    final ids = keys.keys.toList();
    final middle = MediaQuery.sizeOf(context).height / 2;
    var value = 0.0;
    for (var i = 0; i < ids.length; i++) {
      final box =
          keys[ids[i]]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= middle) {
        value = i + ((middle - top) / box.size.height).clamp(0.0, 1.0);
      }
    }
    sceneProgress.value = (value / (ids.length - 1)).clamp(0.0, 1.0);
  }

  void goTo(String id) {
    final box = keys[id]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final target = (scroll.offset + box.localToGlobal(Offset.zero).dy - 90)
        .clamp(0.0, scroll.position.maxScrollExtent);
    scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget sectionFor(String id, Widget child) =>
      KeyedSubtree(key: keys[id], child: child);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;
    return Scaffold(
      endDrawer: wide ? null : _MobileMenu(onNavigate: goTo, active: active),
      body: MouseRegion(
        onHover: (e) {
          final size = MediaQuery.sizeOf(context);
          pointer.value = Offset(
            e.position.dx / size.width * 2 - 1,
            e.position.dy / size.height * 2 - 1,
          );
          cursor.value = e.position;
        },
        onExit: (_) => cursor.value = null,
        child: Stack(
          children: [
            const Positioned.fill(child: StarField()),
            Positioned.fill(
              child: TechGlobe(progress: sceneProgress, pointer: pointer),
            ),
            // Soft glow that follows the mouse (desktop only; touch has no cursor).
            Positioned.fill(
              child: IgnorePointer(child: _CursorGlow(cursor: cursor)),
            ),
            SingleChildScrollView(
              controller: scroll,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  sectionFor(
                    'home',
                    HeroSection(
                      onChat: () => goTo('contact'),
                      onAskAi: () => goTo('ask-my-ai'),
                    ),
                  ),
                  const TechStrip(),
                  sectionFor('solutions', const SolutionsSection()),
                  sectionFor('about', const AboutSection()),
                  sectionFor('tech', const TechSection()),
                  sectionFor(
                    'projects',
                    ProjectsSection(onAskAi: () => goTo('ask-my-ai')),
                  ),
                  sectionFor('process', const ProcessSection()),
                  sectionFor('experience', const ExperienceSection()),
                  sectionFor('community', const CommunitySection()),
                  sectionFor(
                    'ask-my-ai',
                    AskAiSection(onContact: () => goTo('contact')),
                  ),
                  sectionFor('estimate', const EstimatorSection()),
                  sectionFor('contact', const ContactSection()),
                  sectionFor('faq', const FaqSection()),
                  FooterSection(onNavigate: goTo),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _NavBar(active: active, onNavigate: goTo, wide: wide),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: _ScrollProgress(scroll: scroll),
            ),
            Positioned(
              right: 24,
              bottom: 92,
              child: AnimatedScale(
                scale: showTop ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: FloatingActionButton.small(
                  tooltip: 'Back to top',
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.primary,
                  shape: const CircleBorder(
                    side: BorderSide(color: AppColors.borderHover),
                  ),
                  onPressed: () => goTo('home'),
                  child: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large, faint radial glow centred on the mouse pointer.
class _CursorGlow extends StatelessWidget {
  const _CursorGlow({required this.cursor});
  final ValueListenable<Offset?> cursor;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ValueListenableBuilder<Offset?>(
      valueListenable: cursor,
      builder: (context, at, _) => at == null
          ? const SizedBox.shrink()
          : CustomPaint(painter: _GlowPainter(at), size: Size.infinite),
    ),
  );
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.at);
  final Offset at;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 380.0;
    canvas.drawCircle(
      at,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0, 0.4, 1],
        ).createShader(Rect.fromCircle(center: at, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.at != at;
}

/// Thin glowing line along the top that fills as the page scrolls.
class _ScrollProgress extends StatelessWidget {
  const _ScrollProgress({required this.scroll});
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: scroll,
      builder: (context, _) {
        final max = scroll.hasClients && scroll.position.hasContentDimensions
            ? scroll.position.maxScrollExtent
            : 0.0;
        final f = max <= 0 ? 0.0 : (scroll.offset / max).clamp(0.0, 1.0);
        if (f <= 0.001) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: f,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.active,
    required this.onNavigate,
    required this.wide,
  });
  final String active;
  final void Function(String id) onNavigate;
  final bool wide;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1040),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderHover),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onNavigate('home'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo.webp',
                        width: 36,
                        height: 36,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GradientText('AF', style: display(22)),
                    Text(' TECH', style: display(22)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (wide)
              for (final item in navItems)
                _NavLink(
                  label: item.label,
                  active: active == item.id,
                  onTap: () => onNavigate(item.id),
                ),
            IconButton(
              tooltip: 'Search (Ctrl+K)',
              icon: const Icon(Icons.search_rounded, color: AppColors.text),
              onPressed: () => AppState.paletteOpen.value = true,
            ),
            if (!wide)
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu_rounded, color: AppColors.text),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => hover = true),
    onExit: (_) => setState(() => hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: body(
                14.5,
                weight: FontWeight.w600,
                color: widget.active || hover ? AppColors.text : AppColors.dim,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: widget.active ? 20 : 0,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({required this.onNavigate, required this.active});
  final void Function(String id) onNavigate;
  final String active;

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.bg,
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              GradientText('AF', style: display(24)),
              Text(' TECH', style: display(24)),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final item in navItems)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.label,
                style: display(
                  22,
                  color: active == item.id ? AppColors.primary : AppColors.text,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(
                  const Duration(milliseconds: 250),
                  () => onNavigate(item.id),
                );
              },
            ),
        ],
      ),
    ),
  );
}
