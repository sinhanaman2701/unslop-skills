---
name: unslop-design
description: Use when building, restyling, polishing or reviewing the look of an app or web UI, on iOS, Flutter, React Native, SwiftUI or the web, or when a screen looks AI-generated or template-like - purple gradients, glows, emoji as icons, uneven spacing, Material widgets on iOS, everything a pill, shouting copy, a hero with a pill and a gradient headline, or a screen that could belong to any product.
license: CC-BY-4.0
---

# Unslop Design (iOS-first mobile, and web)

Slop fails the same ways everywhere: every surface glows, every label has an emoji, spacing is whatever the model typed, copy shouts, and the platform's own components are replaced by lookalikes. Unslopping fixes the craft and keeps the product: features, content and section order stay; every size, color, word and image becomes deliberate.

**Core principle.** Slop spreads color and effects over the chrome. Craft keeps the chrome quiet and the platform native, and puts the richness into one or two memorable moments of content. A clean screen that could belong to any product is the next template, so every run ends with a screen only this product could have.

**The native test.** Would a fluent user of this platform trust this screen, or pause at off-spec controls? On iOS the tell is "ported from a website or Android": reinvented navigation bars, hamburger drawers, ripples, Material FABs. On web it is "the default AI landing page": a pill, a gradient headline, three icon cards, a logo strip. Default to the platform's components; depart only for a reason the user would thank you for. Platform rules govern structure, navigation and interaction in every mode; brand expresses through tint, type, motion and content.

## Step zero: platform and stack (never skip, never ask what the files already say)

Detect from the project, say what you picked in one line, then load only those references.

| Signal | Platform file | Stack file |
| --- | --- | --- |
| `pubspec.yaml` | `platforms/ios.md` (mobile; add `platforms/web.md` if it also builds web) | `stacks/flutter.md` |
| `package.json` with `react-native` or `expo` | `platforms/ios.md` | `stacks/react-native.md` |
| `*.swift`, `Package.swift`, an Xcode project | `platforms/ios.md` | `stacks/swiftui.md` |
| `index.html`, `package.json` with a web framework, CSS or Tailwind files | `platforms/web.md` | `stacks/web.md` |
| nothing yet (new project) | ask once: which platform and stack | the answer's file |

Mobile is iOS-first (latest iOS); Android conformance is out of scope unless the user asks, and a cross-platform app keeps one shared design system with platform adapters at the shell only. Everything else in this skill (modes, Direction, the passes, signs, tokens) is the same on every platform.

Built on unslop (Damir Sokolovsky, CC BY 4.0; keep this credit in copies), visant-skills (MIT), Impeccable (Apache-2.0), swiftui-microinteractions (MIT), platform-design-skills (MIT) and WCAG 2.2 for the web layer. See `references/credits.md`.

## When to use

- Building or restyling a screen or page: an iOS app (Flutter, React Native, SwiftUI) or a website or web app
- A screen shows slop tells (`references/signs.md`) or "looks AI-made"
- Choosing colors, type, spacing, shapes, glass or imagery

Not for: Android-first apps, motion-only work (**unslop-motion**), scored pre-PR audits (**unslop-review**).

## Modes: ambition scales with the surface

Name the mode from the requested surface, not the product. It decides how far the Direction may reach.

| Mode | Surface | Ambition |
| --- | --- | --- |
| **Operate** | lists, feeds, settings, forms, dashboards, editors (most screens) | precision and restraint; familiar patterns earn their place; brand lives in tint, type, density, one signature move; never a costume of the world's own interface |
| **Persuade** | onboarding, paywall, empty state, marketing screens | the design is what the visitor judges: bold, committed, a point of view; one dominant move plus material, type and spacing that support it |
| **Experience** | showcases, galleries, media-led screens | the artifact leads from the first screen; the interface recedes |
| **Read** | long-form content, help, release notes | structure for comprehension: a calm column in the platform's body style, the world owns only the frame |

A "bolder" or "more experimental" request is a direction decision, not a license for effects: propose two or three directions with trade-offs and wait for the user's pick before building (`references/direction-file.md`). Bold amplifies what the system already owns; it does not add new colors, fonts or effects.

## Run it

0. **Context.** Read the app's direction file if one exists (`references/direction-file.md`); a new screen inherits it and does not re-decide the world. If the product, user or platform is unclear, ask 2 or 3 questions in one round (who uses this and in what situation, the one thing they must do, what must stay untouched), assert the likely answer and invite correction. Skip what the code already answers.
1. **Look.** Run the app and screenshot it (iOS simulator, or a browser at several widths), or read the component tree. Building something new? Draw an ASCII wireframe first: layout, then theme, then motion, then code.
2. **Audit.** `references/signs.md`; list every sign, one line each, with its file.
3. **Mode of work.** Heavy slop: full process. Light slop: polish only, keep palette, type and layout, put bigger ideas in the report. No slop: say so, suggest at most three refinements with exact values, apply only if the user agrees. Never change a good screen to make it different.
4. **Set the Direction and stop.** Five lines below; show audit plus Direction and wait. Skip the wait only when told to just do it.
5. **Fix in order, one pass across the whole screen at a time** (`references/passes.md`; values `tokens.md`; platform rules `platforms/ios.md` or `platforms/web.md`; widgets and code `stacks/<stack>.md`; data elements `data-elements.md`):

   `Spacing -> Color -> Icons -> Copy -> Type -> Layout -> Details -> Glass -> People and visuals -> Motion`

   Spacing first (rhythm changes how everything reads). Copy before type and layout (headline length decides size). Visuals and motion last.
6. **Check** against the checklist, rebuild, compare with the audit list. Render at most three times per run. Say where the evidence came from (simulator, physical device, which browser and widths).
7. **Report per pass as a token panel**, not prose: the named tokens that changed with before and after values, for example `Spacing: gap 14 / gutter 24 / row 64 / filler 0 (banner removed) / chip height 36 / radius 22`, `Colour: canvas grouped, dividers 0, unread count -> dot`, `Type: system font, title large, names 16, body 14`, `Glass: search, button`. Add the Direction and any image prompts. Name what was not verified.
8. **Record** the Direction in the direction file when it is new or changed (from the shipped build, not from intentions).

**REQUIRED SUB-SKILL:** Use unslop-motion for the Motion pass. Before delivering, run **unslop-review** on the result.

## Direction (five lines, derived from the product, never from trends)

- **Product.** What it does and for whom, one plain sentence.
- **Character.** Two or three concrete words (`calm, exact, a little warm`). Banned: clean, modern, sleek, minimal, premium. They describe every template.
- **World.** The place, material or tradition the product belongs to (paper and ink, instruments and night shifts, maps and window light, a printing house). Take it from the audience's life and their graphic traditions, not from the tools they operate (a terminal handed to a working screen comes back as a costume). It sets the accent, chart colors and visuals, not the app surfaces.
- **Moments.** One or two places that get rich color, material and detail: a rendered card, a chart whose colors each mean a series, real photographs, an object from the world.
- **Signature.** One small detail only this product would have, used consistently (a live status dot, a route line, keycaps).

Anti-template test: if someone could guess your aesthetic from the category alone, rework it. AI output clusters in a few looks (warm cream ground with a thin serif and italic accent; near-black with one neon accent and glow; broadsheet hairlines with tracked mono labels; flat saturated ink with hard black shadows); all are legitimate when the brief calls for them, and a failure when reached by reflex. Color strategy before colors: Restrained (tinted neutrals plus one accent, the Operate default), Committed (one color carries 30 to 60 percent), Full palette, Drenched (Persuade and Experience only). Choose light or dark from the use scene (who, where, under what light), not by habit.

Keep a real brand (logo, color, typeface). A violet-to-blue gradient, sparkles and glow are slop even inside a logo unless the user says they are the brand.

## Do not

- Do not rename the product or change its features, content or section order unless asked.
- Do not replace removed decoration with new decoration, or swap one trend for another (glass, grain, neon, bento).
- Do not invent features, claims, data or testimonials; list unverifiable claims and ask.
- Do not use the same look for every product. The Direction decides tint, type and visual.
- Do not apply taste edits silently: only confirmed defects go into the file; style improvements go as a proposal list the user picks from.
- Do not call a screen done from code alone. Build it and look at it.

## Checklist

- [ ] Direction written (or inherited from the direction file); mode named; every pass follows it
- [ ] Spacing on the 4pt scale, equal things equal, groups tighter inside than between; icons, labels and numbers in aligned columns
- [ ] System semantic colors, three text roles, ONE tint with 4.5:1 contrast where text sits on it
- [ ] No hue gradients, gradient text, colored glows, color blobs, side-stripe borders, nested cards
- [ ] No emoji in the interface; one icon set, one size, one weight
- [ ] Platform text styles (iOS text styles, web `rem` scale); text scaling reflows at the largest accessibility size or 200 percent zoom; no uppercase tracked labels, no italic emphasis, no negative tracking on small text
- [ ] No exclamation marks, greeting headlines, unverified claims, hype words; copy names the task; numbers in one format with tabular figures
- [ ] Native structure. iOS: tab bar of sections, large title, sheets with a dismiss, swipe-back intact, 44 pt targets, safe areas, thumb-zone primary action. Web: semantic landmarks, visible current page, real buttons and links, keyboard focus ring, 65-character measure, no layout shift
- [ ] Loading, empty and error are three designed states; error is never rendered as empty
- [ ] Nested radii add up; continuous corners where available; glass (iOS only) on floating controls only, never glass on glass, solid fallback exists; on web no glassmorphism cards
- [ ] Hero, onboarding or empty state has a real visual or product preview with at least one moment, never filler
- [ ] Template check: swap in another product's name; if the screen still fits, push the Direction harder in copy, visual and signature detail
