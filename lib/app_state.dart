import 'package:flutter/material.dart';

import 'content.dart';
import 'widgets/common.dart';

/// Shared actions, so any widget (command palette, case study pages, estimator, floating AI
/// button) can open the assistant, jump to a section or prefill the contact form.
abstract final class AppState {
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Opens the Parlor assistant in a new browser tab.
  static void openAssistant() => openUrl(parlorShareLink);

  /// Whether the Ctrl+K command palette is open.
  static final paletteOpen = ValueNotifier<bool>(false);

  /// Text to put into the contact form's message box (set by the estimator).
  static final contactDraft = ValueNotifier<String>('');

  /// Scrolls the home page to a section; set by the home page while it is mounted.
  static void Function(String id)? scrollTo;

  /// Goes to a section of the home page, returning there first from a case study.
  static void goToSection(String id) {
    final nav = navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.popUntil((r) => r.isFirst);
      Future.delayed(const Duration(milliseconds: 350), () => scrollTo?.call(id));
    } else {
      scrollTo?.call(id);
    }
  }

  static void openCaseStudy(String slug) => navigatorKey.currentState?.pushNamed('/work/$slug');
}
