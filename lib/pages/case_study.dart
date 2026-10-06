import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_state.dart';
import '../content_more.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/tech_globe.dart' show StarField;

/// Full page for one project: the challenge, what was built, the stack and the outcome.
/// Reached at `/#/work/<slug>`, so each case study has its own shareable link.
class CaseStudyPage extends StatelessWidget {
  const CaseStudyPage({super.key, required this.study});
  final CaseStudy study;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final small = w < Breakpoints.tablet;
    final wide = w >= Breakpoints.desktop;
    final s = study;
    final image = s.image.endsWith('.svg')
        ? SvgPicture.asset('assets/images/${s.image}', fit: BoxFit.cover)
        : Image.asset('assets/images/${s.image}', fit: BoxFit.cover);

    Widget block(String title, Widget child) => Reveal(
          child: HoverCard(
            radius: BorderRadius.circular(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title.toUpperCase(), style: body(13, weight: FontWeight.w700, color: AppColors.primary).copyWith(letterSpacing: 1.6)),
              const SizedBox(height: 14),
              child,
            ]),
          ),
        );

    Widget bullets(List<String> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(padding: EdgeInsets.only(top: 3, right: 12), child: Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary)),
                Expanded(child: Text(item, style: body(16, color: AppColors.text))),
              ]),
            ),
        ]);

    final details = [
      block('The challenge', Text(s.challenge, style: body(16.5, color: AppColors.text))),
      block('What I built', bullets(s.built)),
      block('Tech stack', Wrap(spacing: 8, runSpacing: 8, children: [for (final t in s.stack) Tag(t)])),
      block('Outcome', bullets(s.outcome)),
    ];

    return Scaffold(
      body: Stack(children: [
        const Positioned.fill(child: StarField()),
        SingleChildScrollView(
          child: Section(
            vertical: 60,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              PillButton(
                label: 'Back to portfolio',
                compact: true,
                icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.text),
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 36),
              Text('CASE STUDY', style: body(13, weight: FontWeight.w700, color: AppColors.primary).copyWith(letterSpacing: 2)),
              const SizedBox(height: 10),
              ShimmerText(s.title, style: display(small ? 40 : 64)),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(s.tagline, style: body(small ? 17 : 20, color: AppColors.muted)),
              ),
              const SizedBox(height: 22),
              Wrap(spacing: 12, runSpacing: 12, children: [
                for (final (i, (label, url)) in s.links.indexed)
                  PillButton(
                    label: label,
                    primary: i == 0,
                    icon: Icon(url == '#ask-ai' ? Icons.mic_rounded : Icons.open_in_new_rounded, size: 18, color: i == 0 ? Colors.white : AppColors.text),
                    onTap: () {
                      if (url == '#ask-ai') {
                        AppState.openAssistant();
                      } else {
                        openUrl(url);
                      }
                    },
                  ),
              ]),
              const SizedBox(height: 36),
              Reveal(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: AspectRatio(aspectRatio: wide ? 21 / 9 : 3 / 2, child: image),
                ),
              ),
              const SizedBox(height: 36),
              if (wide)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(children: [details[0], const SizedBox(height: 20), details[1]])),
                  const SizedBox(width: 20),
                  Expanded(child: Column(children: [details[2], const SizedBox(height: 20), details[3]])),
                ])
              else
                Column(children: [for (final d in details) Padding(padding: const EdgeInsets.only(bottom: 20), child: d)]),
              const SizedBox(height: 40),
              Center(
                child: Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 14, children: [
                  PillButton(
                    label: 'Start a similar project',
                    primary: true,
                    icon: const Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
                    onTap: () {
                      AppState.contactDraft.value = 'Hi Ahmad, I would like something similar to ${s.title}.\n\n';
                      AppState.goToSection('contact');
                    },
                  ),
                  PillButton(label: 'See all projects', onTap: () => AppState.goToSection('projects')),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
