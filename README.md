# Ahmad Farooq: portfolio (Flutter edition)

The portfolio rebuilt as a Flutter web app: the same content and look as the HTML site
(https://ahmad-farooq-portfolio.vercel.app), written in Dart.

- Responsive layouts for phones, tablets and desktops
- Animated hero (typewriter titles, count-up stats), scroll reveals and hover effects
- 3D tech-stack globe background: your logos on a rotating sphere joined by a glowing network
- Cards in each row share one height, so grids line up
- Floating navigation that highlights the current section; mobile menu
- The live "Ask My AI" assistant from Parlor embedded in an iframe that sizes itself to its content
- Compressed WebP project images and bundled brand icons

## Structure

| File | What it holds |
| --- | --- |
| `lib/content.dart` | Every text, project, job and link on the site |
| `lib/theme.dart` | Colours, fonts and breakpoints |
| `lib/sections/` | One widget per section (`hero.dart`, `sections.dart`, `ask_ai.dart`) |
| `lib/widgets/common.dart` | Shared pieces: buttons, cards, tags, reveal animation, icons |
| `lib/main.dart` | App shell, navigation and scrolling |

## Develop and deploy

```bash
flutter run -d chrome          # develop
python serve.py 8091           # test the built site at http://localhost:8091
flutter build web --release --no-web-resources-cdn --pwa-strategy=none   # build into build/web
```

Vercel serves `build/web` as-is (see `vercel.json`), so **rebuild and commit `build/web`**
after every change, then push.
