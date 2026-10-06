import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../content.dart';
import '../content_more.dart';
import '../theme.dart';
import 'common.dart';

class _Command {
  const _Command(this.label, this.icon, this.run, {this.group = 'Go to'});
  final String label;
  final IconData icon;
  final VoidCallback run;
  final String group;
}

List<_Command> _commands(BuildContext context) => [
  for (final (id, label, icon) in [
    ('home', 'Home', Icons.home_rounded),
    ('solutions', 'Solutions', Icons.auto_awesome_rounded),
    ('about', 'About', Icons.person_rounded),
    ('tech', 'Tech stack', Icons.memory_rounded),
    ('projects', 'Projects', Icons.grid_view_rounded),
    ('process', 'How I work', Icons.timeline_rounded),
    ('experience', 'Experience', Icons.work_rounded),
    ('estimate', 'Estimate your project', Icons.calculate_rounded),
    ('community', 'Community & reviews', Icons.groups_rounded),
    ('ask-my-ai', 'Ask My AI', Icons.graphic_eq_rounded),
    ('contact', 'Contact', Icons.mail_rounded),
    ('faq', 'FAQ', Icons.help_rounded),
  ])
    _Command(label, icon, () => AppState.goToSection(id)),
  _Command('Talk to my AI', Icons.graphic_eq_rounded, AppState.openAssistant, group: 'Actions'),
  _Command('Download CV', Icons.download_rounded, () => openUrl(Links.resume), group: 'Actions'),
  _Command('Copy email address', Icons.copy_rounded, () {
    Clipboard.setData(const ClipboardData(text: Links.email));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Email copied: ${Links.email}')));
  }, group: 'Actions'),
  _Command('Chat on WhatsApp', Icons.chat_rounded, () => openUrl(Links.whatsapp), group: 'Actions'),
  _Command('GitHub', Icons.code_rounded, () => openUrl(Links.github), group: 'Actions'),
  _Command('LinkedIn', Icons.business_center_rounded, () => openUrl(Links.linkedin), group: 'Actions'),
  for (final c in caseStudies)
    _Command('Case study: ${c.title}', Icons.article_rounded, () => AppState.openCaseStudy(c.slug), group: 'Case studies'),
];

/// Ctrl+K / Cmd+K search for every section, case study and action on the site.
class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final query = TextEditingController();
  final focus = FocusNode();
  int selected = 0;

  @override
  void initState() {
    super.initState();
    AppState.paletteOpen.addListener(onOpenChanged);
  }

  void onOpenChanged() {
    if (AppState.paletteOpen.value) {
      query.clear();
      selected = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => focus.requestFocus());
    }
  }

  @override
  void dispose() {
    AppState.paletteOpen.removeListener(onOpenChanged);
    query.dispose();
    focus.dispose();
    super.dispose();
  }

  void close() => AppState.paletteOpen.value = false;

  void run(_Command c) {
    close();
    c.run();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: AppState.paletteOpen,
    builder: (context, open, _) {
      if (!open) return const SizedBox.shrink();
      final words = query.text.toLowerCase().split(' ').where((w) => w.isNotEmpty);
      final matches = [
        for (final c in _commands(context))
          if (words.every((w) => '${c.label} ${c.group}'.toLowerCase().contains(w))) c,
      ];
      if (selected >= matches.length) selected = matches.isEmpty ? 0 : matches.length - 1;
      final size = MediaQuery.sizeOf(context);
      return Positioned.fill(
        child: Stack(children: [
          Positioned.fill(
            child: GestureDetector(onTap: close, child: Container(color: Colors.black.withValues(alpha: 0.6))),
          ),
          Align(
            alignment: const Alignment(0, -0.5),
            child: Container(
              width: (size.width - 32).clamp(0.0, 600.0),
              constraints: BoxConstraints(maxHeight: size.height * 0.7),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderHover),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 50)],
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                type: MaterialType.transparency,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.escape): close,
                      const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                          setState(() => selected = matches.isEmpty ? 0 : (selected + 1) % matches.length),
                      const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                          setState(() => selected = matches.isEmpty ? 0 : (selected - 1 + matches.length) % matches.length),
                    },
                    child: TextField(
                      controller: query,
                      focusNode: focus,
                      autofocus: true,
                      style: body(17, color: AppColors.text, height: 1.3),
                      onChanged: (_) => setState(() => selected = 0),
                      onSubmitted: (_) {
                        if (matches.isNotEmpty) run(matches[selected]);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search sections, projects and actions…',
                        hintStyle: body(17, color: AppColors.dim, height: 1.3),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('ESC', style: body(12, weight: FontWeight.w700, color: AppColors.dim, height: 1.6)),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Flexible(
                    child: matches.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(28),
                            child: Text('Nothing found. Try "projects" or "AI".', style: body(15)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: matches.length,
                            itemBuilder: (context, i) {
                              final c = matches[i];
                              final active = i == selected;
                              final header = i == 0 || matches[i - 1].group != c.group;
                              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                if (header)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                                    child: Text(
                                      c.group.toUpperCase(),
                                      style: body(11.5, weight: FontWeight.w700, color: AppColors.dim, height: 1.2).copyWith(letterSpacing: 1.4),
                                    ),
                                  ),
                                MouseRegion(
                                  onEnter: (_) => setState(() => selected = i),
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => run(c),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: active ? AppColors.cardHover : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(children: [
                                        Icon(c.icon, size: 20, color: active ? AppColors.primary : AppColors.muted),
                                        const SizedBox(width: 14),
                                        Expanded(child: Text(c.label, style: body(15.5, color: AppColors.text, height: 1.3))),
                                        if (active) const Icon(Icons.keyboard_return_rounded, size: 16, color: AppColors.dim),
                                      ]),
                                    ),
                                  ),
                                ),
                              ]);
                            },
                          ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      );
    },
  );
}
