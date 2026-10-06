import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_state.dart';
import '../content.dart';
import '../content_more.dart';
import '../theme.dart';
import '../widgets/common.dart';

// --- How I work ------------------------------------------------------------------------------

class ProcessSection extends StatelessWidget {
  const ProcessSection({super.key});

  static const icons = [Icons.travel_explore_rounded, Icons.design_services_rounded, Icons.construction_rounded, Icons.rocket_launch_rounded];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= Breakpoints.desktop ? 4 : (w >= Breakpoints.tablet ? 2 : 1);
    return Section(
      child: Column(children: [
        const Reveal(
          child: SectionHeader(
            badge: 'How I work',
            title: 'From idea to launch',
            subtitle: 'A simple, transparent process, so you always know what is happening and what comes next.',
          ),
        ),
        LayoutBuilder(builder: (context, c) {
          final width = (c.maxWidth - 20 * (cols - 1)) / cols;
          return Wrap(spacing: 20, runSpacing: 20, children: [
            for (final (i, step) in processSteps.indexed)
              SizedBox(
                width: width,
                child: Reveal(
                  delay: Duration(milliseconds: 140 * i),
                  child: HoverCard(
                    radius: BorderRadius.circular(24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(16)),
                          child: Icon(icons[i], color: Colors.white, size: 26),
                        ),
                        const Spacer(),
                        GradientText('0${i + 1}', style: display(40, color: Colors.white)),
                      ]),
                      const SizedBox(height: 18),
                      Text(step.title, style: display(24)),
                      const SizedBox(height: 8),
                      Text(step.text, style: body(15)),
                      const SizedBox(height: 14),
                      for (final p in step.points)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            const Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(p, style: body(14, color: AppColors.text, height: 1.3)),
                          ]),
                        ),
                    ]),
                  ),
                ),
              ),
          ]);
        }),
      ]),
    );
  }
}

// --- Project estimator ------------------------------------------------------------------------

class EstimatorSection extends StatefulWidget {
  const EstimatorSection({super.key});

  @override
  State<EstimatorSection> createState() => _EstimatorSectionState();
}

class _EstimatorSectionState extends State<EstimatorSection> {
  int type = 0;
  final features = <int>{0};
  bool needDesign = true;
  bool fullProduct = false;

  /// Rough timeline in weeks: base for the product type, plus each feature, plus design, scaled
  /// up for a full product. Shown as a range because every project is different.
  (int, int) get weeks {
    var w = estimateTypes[type].$2;
    for (final f in features) {
      w += estimateFeatures[f].$2;
    }
    if (needDesign) w += 1;
    if (fullProduct) w *= 1.6;
    return ((w * 0.85).floor().clamp(1, 99), (w * 1.3).ceil().clamp(2, 99));
  }

  String get summary {
    final (lo, hi) = weeks;
    return [
      'Hi Ahmad, I used the estimator on your portfolio.',
      'Project: ${estimateTypes[type].$1}',
      if (features.isNotEmpty) 'Features: ${[for (final f in features.toList()..sort()) estimateFeatures[f].$1].join(', ')}',
      'Design: ${needDesign ? 'I need design' : 'I have designs'}',
      'Scope: ${fullProduct ? 'Full product' : 'First version (MVP)'}',
      'Estimated timeline: $lo–$hi weeks',
      '',
    ].join('\n');
  }

  Widget choice(String label, bool selected, VoidCallback onTap) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(onTap),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.gradient : null,
              color: selected ? null : AppColors.card.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? Colors.transparent : AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (selected) ...[const Icon(Icons.check_rounded, size: 16, color: Colors.white), const SizedBox(width: 6)],
              Text(label, style: body(14.5, weight: FontWeight.w600, color: selected ? Colors.white : AppColors.text, height: 1.2)),
            ]),
          ),
        ),
      );

  Widget group(String title, List<Widget> chips) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: display(18)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: chips),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= Breakpoints.desktop;
    final (lo, hi) = weeks;
    final form = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      group('What are you building?', [for (final (i, t) in estimateTypes.indexed) choice(t.$1, type == i, () => type = i)]),
      group('Which features?', [
        for (final (i, f) in estimateFeatures.indexed)
          choice(f.$1, features.contains(i), () => features.contains(i) ? features.remove(i) : features.add(i)),
      ]),
      group('Design', [choice('I need design', needDesign, () => needDesign = true), choice('I have designs', !needDesign, () => needDesign = false)]),
      group('Scope', [choice('First version (MVP)', !fullProduct, () => fullProduct = false), choice('Full product', fullProduct, () => fullProduct = true)]),
    ]);
    final result = GlowBorder(
      radius: 28,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppColors.card.withValues(alpha: 0.95),
          border: Border.all(color: AppColors.borderHover),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ESTIMATED TIMELINE', style: body(13, weight: FontWeight.w700, color: AppColors.primary).copyWith(letterSpacing: 1.6)),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(end: (lo + hi) / 2),
            duration: const Duration(milliseconds: 500),
            builder: (context, _, _) => GradientText('$lo–$hi weeks', style: display(w < Breakpoints.tablet ? 40 : 52)),
          ),
          const SizedBox(height: 10),
          Text('A rough range for planning. I confirm the timeline after a short call about your project.', style: body(14.5)),
          const SizedBox(height: 22),
          PillButton(
            label: 'Send this to Ahmad',
            primary: true,
            icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
            onTap: () {
              AppState.contactDraft.value = summary;
              AppState.goToSection('contact');
            },
          ),
          const SizedBox(height: 12),
          PillButton(
            label: 'Send on WhatsApp',
            icon: const BrandIcon('whatsapp', size: 18),
            onTap: () => openUrl('${Links.whatsapp}?text=${Uri.encodeComponent(summary)}'),
          ),
        ]),
      ),
    );
    return Section(
      child: Column(children: [
        const Reveal(
          child: SectionHeader(
            badge: 'Plan your project',
            title: 'Estimate your project',
            subtitle: 'Pick what you need and see a rough timeline in seconds. No prices, no sign-up.',
          ),
        ),
        Reveal(
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: form),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: result),
                ])
              : Column(children: [form, const SizedBox(height: 8), result]),
        ),
      ]),
    );
  }
}

// --- Contact form -----------------------------------------------------------------------------

/// Saves messages to Supabase (`leads` table, insert-only for visitors), with WhatsApp as a
/// fallback. A hidden "website" field catches simple spam bots.
class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final message = TextEditingController();
  final website = TextEditingController(); // honeypot: people never fill this
  String projectType = 'Not sure yet';
  String budget = 'Not sure yet';
  bool sending = false;
  bool sent = false;
  String error = '';

  static const projectTypes = ['Mobile app', 'Web app', 'Mobile + web', 'AI assistant / automation', 'Something else', 'Not sure yet'];
  static const budgets = ['Under \$500', '\$500 – \$2,000', '\$2,000 – \$5,000', '\$5,000+', 'Not sure yet'];

  @override
  void initState() {
    super.initState();
    AppState.contactDraft.addListener(applyDraft);
    applyDraft();
  }

  void applyDraft() {
    final draft = AppState.contactDraft.value;
    if (draft.isEmpty) return;
    message.text = draft;
    AppState.contactDraft.value = '';
    if (mounted) setState(() => sent = false);
  }

  @override
  void dispose() {
    AppState.contactDraft.removeListener(applyDraft);
    for (final c in [name, email, message, website]) {
      c.dispose();
    }
    super.dispose();
  }

  String get whatsappText =>
      'Hi Ahmad, I am ${name.text.trim().isEmpty ? '(your name)' : name.text.trim()}.\nProject: $projectType\nBudget: $budget\n\n${message.text.trim()}';

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (website.text.isNotEmpty) return setState(() => sent = true); // a bot filled the honeypot
    setState(() {
      sending = true;
      error = '';
    });
    try {
      final res = await http
          .post(
            Uri.parse('$supabaseUrl/rest/v1/leads'),
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode({
              'name': name.text.trim(),
              'email': email.text.trim(),
              'project_type': projectType,
              'budget': budget,
              'message': message.text.trim(),
              'source': 'flutter-portfolio',
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode >= 300) throw Exception('HTTP ${res.statusCode}');
      setState(() => sent = true);
    } catch (_) {
      setState(() => error = 'Your message could not be sent right now. Please use WhatsApp or email instead.');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  InputDecoration deco(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: body(14.5, color: AppColors.dim),
        hintStyle: body(14.5, color: AppColors.dim.withValues(alpha: 0.6)),
        filled: true,
        fillColor: AppColors.bg.withValues(alpha: 0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      );

  Widget dropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: deco(label),
        dropdownColor: AppColors.card,
        style: body(15, color: AppColors.text, height: 1.3),
        items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
        onChanged: (v) => setState(() => onChanged(v ?? value)),
      );

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    if (sent) {
      return Column(children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 56),
        const SizedBox(height: 14),
        Text('Message sent. Thank you!', textAlign: TextAlign.center, style: display(26)),
        const SizedBox(height: 8),
        Text('I usually reply within a day. For anything urgent, WhatsApp is fastest.', textAlign: TextAlign.center, style: body(15.5)),
        const SizedBox(height: 18),
        PillButton(label: 'Send another message', onTap: () => setState(() => sent = false)),
      ]);
    }
    final text = body(15, color: AppColors.text, height: 1.4);
    final twoCols = !small;
    Widget pair(Widget a, Widget b) => twoCols
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), const SizedBox(width: 14), Expanded(child: b)])
        : Column(children: [a, const SizedBox(height: 14), b]);
    return Form(
      key: formKey,
      child: Column(children: [
        pair(
          TextFormField(
            controller: name,
            style: text,
            decoration: deco('Your name'),
            maxLength: 80,
            validator: (v) => (v ?? '').trim().length < 2 ? 'Please enter your name' : null,
          ),
          TextFormField(
            controller: email,
            style: text,
            decoration: deco('Email'),
            maxLength: 120,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim()) ? null : 'Please enter a valid email',
          ),
        ),
        const SizedBox(height: 4),
        pair(
          dropdown('Project type', projectType, projectTypes, (v) => projectType = v),
          dropdown('Budget range', budget, budgets, (v) => budget = v),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: message,
          style: text,
          decoration: deco('Tell me about your project', hint: 'What are you building, who is it for, and when do you need it?'),
          minLines: 4,
          maxLines: 8,
          maxLength: 3000,
          validator: (v) => (v ?? '').trim().length < 10 ? 'A few words about your project, please' : null,
        ),
        // Honeypot: invisible to people, often filled in by bots.
        Offstage(child: TextFormField(controller: website, decoration: const InputDecoration(labelText: 'Website'))),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(error, style: body(14.5, color: const Color(0xFFFFB4B4))),
          ),
        Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
          PillButton(
            label: sending ? 'Sending…' : 'Send message',
            primary: true,
            icon: sending
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
            onTap: sending ? () {} : submit,
          ),
          PillButton(
            label: 'Send on WhatsApp instead',
            icon: const BrandIcon('whatsapp', size: 18),
            onTap: () => openUrl('${Links.whatsapp}?text=${Uri.encodeComponent(whatsappText)}'),
          ),
        ]),
      ]),
    );
  }
}

// --- Testimonials carousel ----------------------------------------------------------------------

class TestimonialCarousel extends StatefulWidget {
  const TestimonialCarousel({super.key});

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 6), (_) => next());
  }

  void next() => setState(() => index = (index + 1) % testimonials.length);
  void prev() => setState(() => index = (index - 1 + testimonials.length) % testimonials.length);

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    final t = testimonials[index];
    Widget arrow(IconData icon, VoidCallback onTap) => IconButton(
          onPressed: () {
            timer?.cancel();
            onTap();
          },
          icon: Icon(icon, color: AppColors.primary),
          style: IconButton.styleFrom(backgroundColor: AppColors.card, side: const BorderSide(color: AppColors.borderHover)),
        );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 860),
      child: Column(children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a), child: child),
          ),
          child: HoverCard(
            key: ValueKey(index),
            padding: EdgeInsets.all(small ? 24 : 40),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 5; i++) const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 22),
              ]),
              const SizedBox(height: 16),
              Text('“${t.quote}”', textAlign: TextAlign.center, style: display(small ? 19 : 24, weight: FontWeight.w500, height: 1.4)),
              const SizedBox(height: 18),
              Text('— ${t.author}', style: body(15.5, weight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          arrow(Icons.chevron_left_rounded, prev),
          const SizedBox(width: 14),
          for (var i = 0; i < testimonials.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: i == index ? AppColors.gradient : null,
                color: i == index ? null : AppColors.dim.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          const SizedBox(width: 14),
          arrow(Icons.chevron_right_rounded, next),
        ]),
      ]),
    );
  }
}
