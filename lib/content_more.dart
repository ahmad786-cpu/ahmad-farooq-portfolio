// Content for the case studies, process, estimator and contact features.
// Facts come from the CV and the projects themselves; nothing here is a made-up metric.

/// Where "Book a call" goes. Paste a Google Calendar booking page or Calendly link here;
/// while it is empty, the button opens WhatsApp with a booking message instead.
const bookCallUrl = '';

/// Supabase project that stores contact-form messages (table `leads`, insert-only for visitors).
const supabaseUrl = 'https://qlvyfsryncelrfhskhor.supabase.co';
// The public (anon) key: safe in a website; row level security only allows inserting leads.
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsdnlmc3J5bmNlbHJmaHNraG9yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA5Mjk5ODgsImV4cCI6MjEwNjUwNTk4OH0.b6xmGHVTqOYsnb2Ts7yTH9vqNm5NOv9sOY3gTKms5IU';

class CaseStudy {
  const CaseStudy({
    required this.slug,
    required this.title,
    required this.tagline,
    required this.image,
    required this.challenge,
    required this.built,
    required this.stack,
    required this.outcome,
    required this.links,
  });
  final String slug; // URL: /#/work/<slug>
  final String title;
  final String tagline;
  final String image;
  final String challenge;
  final List<String> built;
  final List<String> stack;
  final List<String> outcome;
  final List<(String label, String url)> links;
}

const caseStudies = [
  CaseStudy(
    slug: 'parlor',
    title: 'Parlor',
    tagline: 'AI personalities you can talk to by voice, shared with a single link.',
    image: 'parlor.svg',
    challenge:
        'People want AI assistants with a real personality and voice that anyone can try instantly, without accounts or installs, while the instructions behind them stay private.',
    built: [
      'Personalities with their own name, behaviour, greeting, colour, language and voice',
      'Voice calls: speech recognition in the browser, replies streamed live from the language model and spoken sentence by sentence',
      'A server voice, so a personality sounds the same on every phone and computer',
      'Google sign-in, conversation history, and public share links that never reveal the prompt',
      'An embeddable mode that sizes itself to the host page; it powers the Ask My AI assistant on this site',
      'Per-visitor rate limits and abuse checks, so share links cannot run up the bill',
    ],
    stack: ['Next.js', 'TypeScript', 'Supabase', 'Groq (LLM + TTS)', 'Web Speech API', 'Vercel'],
    outcome: ['Live in production', 'Mobile-friendly, down to 280px screens', 'Powers the assistant on this portfolio'],
    links: [('Try it', '#ask-ai'), ('GitHub', 'https://github.com/ahmad786-cpu/parlor')],
  ),
  CaseStudy(
    slug: 'legal-slack-ai',
    title: 'AI Legal Slack Organization',
    tagline: 'A legal team assistant that reads documents and answers with sources, inside Slack.',
    image: 'ai_legal_slack.svg',
    challenge:
        'Legal teams lose hours searching contracts and emails for dates and obligations. They needed answers they can verify, deadlines they will not miss, and drafts they can start from.',
    built: [
      'Reads Word, PDF, scanned images and emails (including attachments) dropped into a Slack channel',
      'Retrieval-augmented generation: answers questions from the documents and cites each source',
      'Automatic analysis of every document: summary, parties, key dates, obligations and risks',
      'A running brief per matter that updates as new documents arrive',
      'One-click Google Calendar events for deadlines, and document drafts delivered as Word files',
    ],
    stack: ['Node.js', 'TypeScript', 'Slack', 'Pinecone', 'Embeddings', 'Supabase', 'Google Calendar', 'Vercel'],
    outcome: ['Open source on GitHub', 'Deployed on Vercel', 'Tested end to end on real document types'],
    links: [('GitHub', 'https://github.com/ahmad786-cpu/legal-slack-ai')],
  ),
  CaseStudy(
    slug: 'zyro-cloud',
    title: 'Zyro Cloud',
    tagline: 'One source of truth for e-commerce operations across three marketplaces.',
    image: 'zyro_cloud.webp',
    challenge:
        'Merchants selling on Shopify, Daraz and WooCommerce juggled three dashboards, and stock went out of sync between them.',
    built: [
      'A single dashboard for orders, inventory and customers from all three marketplaces',
      'A multi-tenant data model that keeps inventory consistent across three independent marketplace APIs',
      'WhatsApp AI messaging automation for customers',
      'Courier tracking and automated Meta Ads analytics reporting',
    ],
    stack: ['React Native', 'Node.js', 'WhatsApp AI', 'Meta Ads API', 'Shopify', 'WooCommerce', 'Daraz'],
    outcome: ['Live at zyroocloud.com'],
    links: [('Visit Zyro Cloud', 'https://www.zyroocloud.com')],
  ),
  CaseStudy(
    slug: 'routebuddy',
    title: 'RouteBuddy',
    tagline: 'A carpooling platform for daily commuters, with an AI assistant in Roman Urdu.',
    image: 'routebuddy.webp',
    challenge: 'Commuters needed a safe, affordable way to share rides, with payments and support that fit how people in Pakistan actually pay and talk.',
    built: [
      'The mobile app, its Firebase backend and a Flutter Web admin panel',
      'Real-time ride matching and fare bidding',
      'Local payments: JazzCash, Easypaisa and Safepay',
      'An AI assistant that understands Roman Urdu',
      'Admin tools for user management, verification, ride oversight and moderation',
    ],
    stack: ['Flutter', 'Firebase', 'Flutter Web', 'Google Maps'],
    outcome: ['Live on Google Play'],
    links: [('Google Play', 'https://play.google.com/store/apps/details?id=com.routebuddy.app')],
  ),
  CaseStudy(
    slug: 'enterprise-crm',
    title: 'Enterprise CRM System',
    tagline: 'A CRM with AI-powered insights and workflow automation.',
    image: 'enterprise_crm.svg',
    challenge: 'A sales operation needed customer data, automation and insight in one place instead of spreadsheets and manual follow-ups.',
    built: ['AI-powered customer insights', 'Workflow automation', 'Analytics and customer intelligence'],
    stack: ['CRM', 'Automation', 'Analytics'],
    outcome: ['In production use'],
    links: [('Live site', 'https://medicare.elite-calls.com/')],
  ),
  CaseStudy(
    slug: 'buddycart',
    title: 'BuddyCart.pk',
    tagline: 'An online store that markets itself on social media and WhatsApp.',
    image: 'buddycart.webp',
    challenge: 'A local store needed online sales with Pakistani payment methods, and no time to post every product to social media by hand.',
    built: [
      'A custom store on PHP and MySQL',
      'Automatic Facebook and Instagram posting through the Meta Graph API',
      'WhatsApp order notifications',
      'JazzCash and Easypaisa checkout',
    ],
    stack: ['PHP', 'MySQL', 'Meta Graph API', 'WhatsApp'],
    outcome: ['Live at buddycartpk.com'],
    links: [('Visit the store', 'https://buddycartpk.com/')],
  ),
];

CaseStudy? caseStudyFor(String projectTitle) {
  final key = projectTitle.toLowerCase();
  for (final c in caseStudies) {
    if (key.startsWith(c.title.toLowerCase()) || c.title.toLowerCase().startsWith(key)) return c;
  }
  return null;
}

class ProcessStep {
  const ProcessStep(this.title, this.text, this.points);
  final String title;
  final String text;
  final List<String> points;
}

const processSteps = [
  ProcessStep('Discover', 'We talk about your goals, your users and what success looks like.', ['Goals & users', 'Scope & priorities', 'Clear next steps']),
  ProcessStep('Design', 'I map the flows and the architecture, and give you a realistic timeline.', ['User flows & UI', 'Architecture', 'Timeline']),
  ProcessStep('Build', 'Weekly demos you can click through, so feedback comes early, while changes are cheap.', ['Weekly demos', 'AI & integrations', 'Testing']),
  ProcessStep('Launch', 'Deployment, monitoring and a clean handover, with support after go-live.', ['Deploy & monitor', 'Handover & docs', 'Ongoing support']),
];

/// Estimator choices: label and the weeks each one adds.
const estimateTypes = [
  ('Mobile app (iOS & Android)', 3.0),
  ('Web app', 3.0),
  ('Mobile + web', 5.0),
  ('AI assistant / automation', 2.0),
];

const estimateFeatures = [
  ('Sign-in & profiles', 0.5),
  ('Payments', 1.0),
  ('Maps & location', 1.0),
  ('Chat & messaging', 1.5),
  ('Admin dashboard', 1.5),
  ('AI features (chat, voice, RAG)', 1.5),
  ('Notifications', 0.5),
  ('Offline mode', 1.0),
  ('Integrations (Shopify, WhatsApp, Slack…)', 1.0),
];
