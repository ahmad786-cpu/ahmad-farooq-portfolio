import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';

/// Floating "Talk to my AI" button, visible on every screen. It opens the Parlor assistant in a
/// new browser tab.
class AiFab extends StatelessWidget {
  const AiFab({super.key});

  @override
  Widget build(BuildContext context) => const _Button(onTap: AppState.openAssistant);
}

class _Button extends StatefulWidget {
  const _Button({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> with SingleTickerProviderStateMixin {
  late final pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  bool hover = false;

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Tooltip(
      message: 'Talk to my AI',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: pulse,
            builder: (context, child) => Container(
              padding: EdgeInsets.symmetric(horizontal: small ? 14 : 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.55 * (1 - pulse.value)),
                    blurRadius: 4 + 22 * pulse.value,
                    spreadRadius: 10 * pulse.value,
                  ),
                ],
              ),
              child: child,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 22),
              if (!small || hover) ...[
                const SizedBox(width: 8),
                Text('Talk to my AI', style: body(15, weight: FontWeight.w700, color: Colors.white, height: 1.2)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
