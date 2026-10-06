import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// "Ask My AI": a card with a button that opens the Parlor assistant in a new browser tab, where
/// the microphone and voice work without any embedding limits.
class AskAiSection extends StatelessWidget {
  const AskAiSection({super.key, required this.onContact});
  final VoidCallback onContact;

  static const _examples = [
    'What AI projects have you built?',
    'How would you build my app idea?',
    'Which tech stack do you use?',
  ];

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Section(
      child: Column(
        children: [
          const Reveal(
            child: SectionHeader(
              badge: 'Built with Parlor',
              title: 'Ask My AI',
              subtitle:
                  'Talk to an AI version of me about my work, skills and projects, or describe your idea and get a first take on how to build it.',
            ),
          ),
          Reveal(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: GlowBorder(
                radius: 32,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: small ? 40 : 56,
                    horizontal: small ? 22 : 48,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.borderHover),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.card.withValues(alpha: 0.95),
                        AppColors.bg.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const _Orb(),
                      const SizedBox(height: 26),
                      Text(
                        'Talk or type, it answers like me',
                        textAlign: TextAlign.center,
                        style: display(small ? 26 : 32),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The assistant opens in a new tab. Start a voice call or type a message.',
                        textAlign: TextAlign.center,
                        style: body(16),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final q in _examples)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bg.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '“$q”',
                                style: body(14, color: AppColors.text, height: 1.3),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          PillButton(
                            label: 'Open my AI assistant ↗',
                            primary: true,
                            icon: const Icon(
                              Icons.graphic_eq_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            onTap: AppState.openAssistant,
                          ),
                          PillButton(label: 'Contact me directly', onTap: onContact),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Voice works best in Chrome or Edge. Answers are AI-generated; for a quote, contact me directly.',
                        textAlign: TextAlign.center,
                        style: body(13.5, color: AppColors.dim),
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

/// Pulsing gradient orb with a sound-wave icon.
class _Orb extends StatefulWidget {
  const _Orb();

  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
  late final pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    builder: (context, child) => Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.6 * (1 - pulse.value)),
            blurRadius: 10 + 30 * pulse.value,
            spreadRadius: 18 * pulse.value,
          ),
        ],
      ),
      child: child,
    ),
    child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 44),
  );
}
