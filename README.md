# unslop-skills

I took everything I could find on de-slopping AI-generated UI and collated it into three [Claude Code](https://claude.com/claude-code) skills: design, motion and review. iOS-first, and they work for Flutter, React Native, SwiftUI and the web.

Built on [unslop](https://github.com/heydamir/unslop) by Damir Sokolovsky ([@heydamir](https://x.com/heydamir)), plus Visant, Impeccable and platform-design-skills (see [Credits](#credits-and-licenses)).

| Skill | Use it when |
| --- | --- |
| [`unslop-design`](skills/unslop-design) | You are building or restyling a screen: spacing, color, type, hierarchy, copy, platform fit. |
| [`unslop-motion`](skills/unslop-motion) | You are adding or fixing animation, gestures, press feedback, haptics or loading behavior. |
| [`unslop-review`](skills/unslop-review) | You want a scored audit of a screen or flow before a PR or release, with a candidate scanner (`slop-grep.sh`). |

## How they are built

The rules (a Direction, ordered passes, signs of slop, tokens, a review gate) are stack-neutral. A platform layer (`ios`, `ios-glass`, `web`) sits on top, then a stack adapter: Flutter, React Native, SwiftUI or web. Each skill detects the stack from the project (`pubspec.yaml`, `package.json`, Swift sources, HTML/CSS) before it writes any code.

## Install

Global, for every project:

```sh
git clone https://github.com/sinhanaman2701/unslop-skills.git
mkdir -p ~/.claude/skills
cp -R unslop-skills/skills/* ~/.claude/skills/
```

Restart Claude Code. The skills trigger from their descriptions, or ask for them by name.

## Verification status

Be aware of what was and was not run:

- **Flutter**: built and run on an iOS simulator (iPhone and iPad), with widget tests.
- **Web**: built and run in Chrome at 320 to 1280 px, light and dark, reduced motion, keyboard only.
- **React Native**: example type-checked with `tsc --strict` and scanned only. It was never run on a simulator or device, so layout, gestures and haptics are unverified.
- **SwiftUI**: the adapters are the thinnest and have not been tested on a real app.
- **Android** is out of scope.
- `bash skills/unslop-review/scripts/slop-grep.sh --self-test` checks the scanner against fixtures for Flutter, React Native and web. The scanner reports candidates, not verdicts.

## Credits and licenses

These skills adapt ideas and text structure from other people's work. Each skill carries its own `references/credits.md`; keep it in any copy.

- All three skills build on [unslop](https://github.com/heydamir/unslop) by Damir Sokolovsky (CC BY 4.0): `unslop-design` uses its Direction, passes and signs of slop, `unslop-motion` its motion pass, `unslop-review` its sign catalog. Credit travels with any copy.
- They also draw on Visant (MIT), Impeccable by Paul Bakaus (Apache-2.0), platform-design-skills by ehmo (MIT) and swiftui-microinteractions by Vishal Paliwal (MIT).
- `unslop-design` declares `CC-BY-4.0` in its frontmatter; `unslop-motion` and `unslop-review` declare `MIT`. The `LICENSE` file (MIT) covers the original work in this repo; material adapted from the sources above keeps the terms in each `credits.md`.
