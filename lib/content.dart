// Everything the portfolio says, in one place. Kept in step with the CV and the HTML site.

const parlorShareLink =
    'https://parlor-navy-six.vercel.app/dashboard/personality-demo?token=AhmadFarooq-wjX87';

abstract final class Links {
  static const linkedin = 'https://linkedin.com/in/ahmad-farooq-57bb771bb';
  static const github = 'https://github.com/ahmad786-cpu';
  static const fiverr = 'https://www.fiverr.com/s/WE2aPoQ';
  static const whatsapp = 'https://wa.me/923475776857';
  static const email = 'ahmadfarooq5581@gmail.com';
  static const resume = 'resume.pdf';
}

const roles = [
  'an AI Developer',
  'a Full-Stack Developer',
  'a Flutter Developer',
  'a React Native Developer',
  'an Automation Engineer',
  'a Product Engineer',
  'a Tech Lead',
];

class Stat {
  const Stat(this.value, this.suffix, this.label);
  final int value;
  final String suffix;
  final String label;
}

const heroStats = [
  Stat(50, '+', 'Projects Delivered'),
  Stat(30, '+', 'Happy Clients'),
  Stat(5, '+', 'Years Experience'),
  Stat(100, '%', 'Client Satisfaction'),
];

class Solution {
  const Solution(this.title, this.text, this.points, this.icon);
  final String title;
  final String text;
  final List<String> points;
  final String icon; // Material icon name, resolved in the widget
}

const solutions = [
  Solution(
    'AI Assistants & Automation',
    'I build AI assistants, voice agents and RAG systems on OpenAI, Claude and Gemini, and automate the repetitive work between your tools.',
    ['Voice & Chat Agents', 'RAG on Your Data', 'Workflow Automation'],
    'ai',
  ),
  Solution(
    'Scalable Architecture',
    'I design backend systems built to scale from day one, with clean, maintainable code and modern cloud infrastructure at the core.',
    ['Strong Backend', 'Cloud Setup', 'Fast Systems'],
    'arch',
  ),
  Solution(
    'Modern Mobile Apps',
    'I build cross-platform iOS and Android apps with Flutter and React Native: fast, fluid and polished on every screen size.',
    ['iOS & Android', 'Fast Loading', 'Smooth Scrolling'],
    'mobile',
  ),
  Solution(
    'UI/UX Strategy',
    'I translate your goals into intuitive, beautiful interfaces, designed to keep users engaged and coming back.',
    ['Modern Design', 'Easy to Use', 'Fast Feedback'],
    'design',
  ),
];

class TechItem {
  const TechItem(this.name, [this.icon]);
  final String name;
  final String? icon; // file in assets/icons, without extension
}

class TechCategory {
  const TechCategory(this.title, this.icon, this.items);
  final String title;
  final String icon;
  final List<TechItem> items;
}

const techStack = [
  TechCategory('AI & Agents', 'anthropic', [
    TechItem('OpenAI'),
    TechItem('Claude', 'anthropic'),
    TechItem('Gemini', 'googlegemini'),
    TechItem('MCP'),
    TechItem('RAG'),
    TechItem('Pinecone'),
  ]),
  TechCategory('Mobile', 'flutter', [
    TechItem('Flutter', 'flutter'),
    TechItem('Dart', 'dart'),
    TechItem('React Native', 'react'),
    TechItem('Kotlin', 'kotlin'),
    TechItem('BLoC'),
    TechItem('Riverpod'),
  ]),
  TechCategory('Web', 'nextdotjs', [
    TechItem('Next.js', 'nextdotjs'),
    TechItem('React', 'react'),
    TechItem('JavaScript', 'javascript'),
    TechItem('HTML5', 'html5'),
    TechItem('CSS', 'css'),
  ]),
  TechCategory('Backend', 'nodedotjs', [
    TechItem('Node.js', 'nodedotjs'),
    TechItem('Express.js', 'express'),
    TechItem('NestJS', 'nestjs'),
    TechItem('Python', 'python'),
    TechItem('PHP', 'php'),
    TechItem('Postman', 'postman'),
  ]),
  TechCategory('Data & Cloud', 'supabase', [
    TechItem('Supabase', 'supabase'),
    TechItem('Firebase', 'firebase'),
    TechItem('PostgreSQL', 'postgresql'),
    TechItem('MongoDB', 'mongodb'),
    TechItem('Redis', 'redis'),
    TechItem('Google Cloud', 'googlecloud'),
    TechItem('Vercel', 'vercel'),
  ]),
  TechCategory('Tools & Design', 'figma', [
    TechItem('GitHub', 'github'),
    TechItem('GitLab', 'gitlab'),
    TechItem('Jira', 'jira'),
    TechItem('Figma', 'figma'),
    TechItem('Adobe XD'),
    TechItem('Canva'),
  ]),
];

class ProjectLink {
  const ProjectLink(this.label, this.url, {this.kind = LinkKind.web});
  final String label;
  final String url;
  final LinkKind kind;
}

enum LinkKind { web, github, store, internal }

class Project {
  const Project(
    this.title,
    this.description,
    this.tags,
    this.image,
    this.links,
  );
  final String title;
  final String description;
  final List<String> tags;
  final String image; // assets/images file
  final List<ProjectLink> links;
}

const projects = [
  Project(
    'Parlor',
    'Create AI personalities with their own behaviour and voice, then talk to them by voice or text. Replies stream live from a language model and are spoken sentence by sentence, with Google sign-in, conversation history and public share links.',
    ['AI', 'Next.js', 'Voice', 'Supabase'],
    'parlor.svg',
    [
      ProjectLink(
        'GitHub',
        'https://github.com/ahmad786-cpu/parlor',
        kind: LinkKind.github,
      ),
      ProjectLink('Try It', '#ask-my-ai', kind: LinkKind.internal),
    ],
  ),
  Project(
    'Enterprise CRM System',
    'Comprehensive CRM with AI-powered insights, automation, and customer intelligence.',
    ['CRM', 'Automation', 'Analytics'],
    'enterprise_crm.svg',
    [ProjectLink('Live Site', 'https://medicare.elite-calls.com/')],
  ),
  Project(
    'AI Legal Slack Organization',
    'AI-powered legal document management and RAG system built with OpenAI, Pinecone and embeddings. It processes DOCX, PDF, image and email files, keeps legal context up to date automatically, runs AI analysis, schedules through Google Calendar, and generates documents.',
    ['OpenAI', 'RAG', 'Pinecone', 'Slack'],
    'ai_legal_slack.svg',
    [
      ProjectLink(
        'GitHub',
        'https://github.com/ahmad786-cpu/legal-slack-ai',
        kind: LinkKind.github,
      ),
    ],
  ),
  Project(
    'Zyro Cloud',
    'All-in-one e-commerce operations platform unifying orders, inventory and customers across Shopify, Daraz and WooCommerce, with WhatsApp AI automation, courier tracking and Meta Ads analytics.',
    ['SaaS', 'WhatsApp AI', 'Multi-Platform'],
    'zyro_cloud.webp',
    [ProjectLink('Live Demo', 'https://www.zyroocloud.com')],
  ),
  Project(
    'BuddyCart.pk',
    'Custom-built online store on plain PHP and MySQL, with automated Facebook and Instagram posting via the Meta Graph API, WhatsApp order notifications, and local JazzCash / EasyPaisa checkout.',
    ['PHP', 'E-commerce', 'Meta API'],
    'buddycart.webp',
    [ProjectLink('Visit Store', 'https://buddycartpk.com/')],
  ),
  Project(
    'RouteBuddy',
    'Carpooling platform with real-time ride matching, fare bidding, local payments, a Roman Urdu AI assistant and a Flutter Web admin panel for moderation.',
    ['Flutter', 'Firebase', 'Google Maps'],
    'routebuddy.webp',
    [
      ProjectLink(
        'Play Store',
        'https://play.google.com/store/apps/details?id=com.routebuddy.app',
        kind: LinkKind.store,
      ),
    ],
  ),
  Project(
    'SkillBuddy',
    'Hyperlocal service marketplace connecting skilled workers with nearby clients: book, track and pay in one app.',
    ['Flutter', 'Firebase', 'Geolocation'],
    'skillbuddy.webp',
    [],
  ),
  Project(
    'Flappy Dash Game',
    'Arcade game with custom physics and global leaderboards.',
    ['Flutter', 'Flame', 'Game'],
    'flappy_dash_game.webp',
    [],
  ),
  Project(
    'Dukan e Khata',
    'Digital ledger for small businesses with offline-first storage, cloud sync and automated reporting.',
    ['Flutter', 'Dart', 'Drift', 'Supabase'],
    'dukan_e_khata.webp',
    [],
  ),
  Project(
    'HomeHaven Marketplace',
    'Property booking with real-time availability and payments.',
    ['Flutter', 'NestJS', 'Stripe'],
    'homehaven_marketplace.webp',
    [],
  ),
  Project(
    'Titan VPN',
    'High-speed VPN client with encrypted tunnelling and server selection.',
    ['Security', 'Networking', 'Flutter'],
    'titan_vpn.webp',
    [],
  ),
  Project(
    'Kardly Branding',
    'Automated branding platform for business cards and letterheads.',
    ['Automation', 'Design', 'Flutter'],
    'kardly_branding.webp',
    [
      ProjectLink(
        'Play Store',
        'https://play.google.com/store/apps/details?id=com.kardly.app',
        kind: LinkKind.store,
      ),
    ],
  ),
  Project(
    'Shortify AI Tool',
    'AI-powered content summarizer using Google Gemini.',
    ['Gemini AI', 'ML', 'Flutter'],
    'shortify_ai_tool.webp',
    [],
  ),
];

class Job {
  const Job(
    this.period,
    this.title,
    this.place,
    this.summary,
    this.points,
    this.tags,
  );
  final String period;
  final String title;
  final String place;
  final String summary;
  final List<String> points;
  final List<String> tags;
}

// From the current CV.
const jobs = [
  Job(
    '2019 – Present',
    'Contract & Freelance Full Stack Engineer',
    'Self-employed • Remote',
    'Direct clients and Fiverr, including long-running contracts with Tech Solutions (2022 – present) and Innovation Lab (2021 – 2022).',
    [
      'Delivered 50+ projects for 30+ international clients across web, mobile, e-commerce and automation, with a 100% client satisfaction rating.',
      'Sole technical owner from scoping and estimation through architecture, build, deployment, monitoring and handover.',
      'Build AI assistants, voice agents and RAG systems with OpenAI, Claude and Gemini, plus automations that replace manual data entry and reporting.',
    ],
    ['Node.js', 'Python', 'Next.js', 'AI & RAG', 'Automation'],
  ),
  Job(
    'Jan 2021 – Present',
    'Mobile Application Developer',
    'ITech Computer Institute & Software House • Haripur',
    'Own delivery of client applications from architecture to production release, including versioning, staged rollout and post-launch support.',
    [
      'Build React Native and Flutter apps backed by REST APIs, Google Maps, Stripe, push notifications and OAuth providers.',
      'Improve rendering performance, memory use and startup time across a wide range of device tiers.',
      'Lead code reviews, set the team\'s architecture and state-management standards, and mentor junior developers.',
    ],
    ['Flutter', 'React Native', 'REST APIs', 'Code Review', 'Mentoring'],
  ),
  Job(
    '2018 – 2022',
    'BS Computer Science',
    'University of Haripur',
    'CGPA 3.26 / 4.00. Final year project: a camera-based automated attendance system built with Python and OpenCV.',
    [],
    ['Python', 'OpenCV', 'Computer Science'],
  ),
];

class Testimonial {
  const Testimonial(this.quote, this.author);
  final String quote;
  final String author;
}

const testimonials = [
  Testimonial(
    "Ahmad's attention to detail and ability to solve complex problems is unmatched. He delivered our MVP ahead of schedule.",
    'Tech Founder, Dubai',
  ),
  Testimonial(
    "One of the most reliable Flutter developers I've worked with. His code is clean and highly maintainable.",
    'Project Lead, Innovation Lab',
  ),
];

const communityStats = [
  Stat(3, '', 'Global Communities'),
  Stat(50, '+', 'Hosted Events'),
  Stat(2500, '+', 'In-person Engagements'),
];

class Faq {
  const Faq(this.question, this.answer);
  final String question;
  final String answer;
}

const faqs = [
  Faq(
    'What services does Ahmad Farooq offer?',
    'End-to-end product development: AI assistants and automation, full stack web apps, Flutter and React Native mobile apps, and Node.js or Python backends, so I can take your product from concept to launch.',
  ),
  Faq(
    'How much experience do you have?',
    'I have 5+ years of professional experience and have delivered 50+ projects for clients around the world.',
  ),
  Faq(
    'Are you available for new projects?',
    "Yes, I'm currently available for new projects, from startup MVPs to enterprise builds, with a focus on quality and fast turnaround.",
  ),
  Faq(
    'What is your typical project workflow?',
    'My process is straightforward: understand your goals, design the solution, then build and rigorously test before launch.',
  ),
];
