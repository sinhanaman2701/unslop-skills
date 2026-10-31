# The app's direction file, intake, and bold proposals

One Direction per app, written down, so every screen stays in the same world without re-deciding it. (Pattern from Impeccable's PRODUCT.md and DESIGN.md, Visant's preflight and scars, and unslop's Direction.)

## Where it lives

`docs/design/DIRECTION.md` (or `DESIGN.md` at the repo root if the project already uses one). Read it first on every run. Write or update it **from the shipped build, not from intentions**: a rulebook written before the build gets defended against reality instead of describing it. Update it only when the system really changed; an ordinary new screen inherits it and does not rewrite it. Never copy it into app source or assets. If a file already exists, show it and offer refresh, merge or leave; never overwrite silently.

## Template

```markdown
---
name: <App>
description: <one line>
platform: ios          # ios | adaptive (iPhone and iPad) | cross-platform with iOS look
tint: { light: "#0A5FD8", dark: "#5B9BFF" }   # the ONE interactive color, both appearances
colors: { <slug>: "<value>" }                  # named by role, not blue-800
typography: { family: system | <brand font + where it is allowed>, scale: ios-text-styles }
rounded: { control: 12, card: 20, sheet: 28 }
spacing: [4, 8, 12, 16, 20, 24, 32, 40, 48, 64]
motion: <path of the token file>                # lib/ui/motion.dart, src/motion.ts, styles/motion.css
---

# Design direction: <App>

## Overview
**Creative north star: "<a named metaphor>"** then two or three sentences: personality, density,
what it refuses. Product, Character (2-3 concrete words), World, Moments, Signature, in one line each.

## Colors
Palette character in a sentence; each color with its role and where it appears.
Named rules, short and forceful: "The One Voice Rule: the tint covers at most about 10 percent of any screen."

## Typography
Families and where the display face is allowed. Roles used (iOS text styles). Tabular figures for numbers.

## Layout
Which surfaces are Operate, Persuade, Experience, Read. Density. Grouped lists vs custom. iPad behavior.

## Elevation and depth
Surface steps, hairline usage, shadow policy, where glass is allowed (floating controls only) and its fallback.

## Shapes
Radius scale, nested radius rule, continuous corners.

## Components
Which are the platform's own components as-is (Cupertino, native-stack, `dialog`), which are custom and why (one line each).

## Motion
Archetypes used, haptic policy, Reduce Motion behavior.

## Do's and Don'ts
Only rules this app earned. Check each prohibition against the world's own materials: a ban on a device the
world itself uses natively, or a value recorded only to make a finding disappear, are both errors.

## Scars
Defensive decisions that must survive a rewrite: "opaque background required under the hero numbers or the
decoration cuts through" (measured, date). Before rewriting a screen completely, list its defensive
comments and carry each one, or justify in writing why it no longer applies.
```

## Intake: one round, two or three questions

Ask only what the repository and the request do not answer, as assertions the user can correct. Never ask for hex values, fonts or "a vibe".

1. Who uses this, in what situation and state of mind? What is the one thing they must understand or do? What would success look like?
2. What is uniquely true here that a neighboring product or a generic template could not claim?
3. What must stay untouched, and what would make the result feel wrong even if it looked polished? (Ask about the brand's untouchable elements: a "cleaner" version that swaps the brand's own graphic language for a conventional one is reverted in one sentence.)

Second round only for a material gap: real content ranges (minimum, typical, longest name, largest number), which states matter (first run, empty, loading, error, permissions, overflow), and binding constraints (platform, performance, localization, accessibility). Questions asked later in the work always arrive after the rework they would have prevented, so ask them once, up front.

## Preflight for a big redesign (a day or more of work)

Five premise checks, each born from a real mistake; do not run them for a tweak.

1. **Brand source of truth.** The brand vault, the tokens file and the files the client actually delivered agree on type, colors, logo and tagline. The delivered folder is stronger evidence than a stored field.
2. **Fonts load.** Each family is bundled (declared in `pubspec.yaml`, app assets or `@font-face`) or licensed; a missing font does not error, it silently falls back to the system face and the product changes voice.
3. **Imagery can carry the layout.** Choose the source by resolution before deciding the framing: about 3x the display size for full-bleed images. List every image you read and every one you skipped; never filter silently.
4. **Brand files exist.** Vector logo, light and dark variants, a square app icon. If they do not exist, ask for them; never redraw a brand by approximation.
5. **Every number has a source.** A figure lifted from a mockup is not a primary source: mark it pending or leave it out.

Write the answers in the direction file before the first line of UI.

## Bold or experimental requests

"Bolder", "more experimental", "make it feel like the future" are direction decisions. Do not start building effects.

1. Think through two or three different directions (different technique, level of ambition, aesthetic). For each, describe in plain words what the result looks and feels like, and state the trade-offs: performance cost, package or platform requirements, fallback on older iOS and on Android, how it affects accessibility.
2. Get the user's pick before writing code.
3. Build only the confirmed direction. Bold amplifies what the system already owns (its motif, type scale and devices at full strength for this one target); everything outside the named target stays unchanged; no new colors, fonts or primitives appear unasked. Commit to one decisive move, then quiet everything around it; if every element got louder, the screen got flatter.
4. Progressive enhancement is not optional: the experience without the effect must still be good. Keep content visible by default; target 60 fps and test on a mid-range device; do not mask weak fundamentals with technique (fix spacing, type and hierarchy first); never add sound without opt-in; never layer several competing showpieces.
5. Verify with the skeleton test (strip the copy: does the structure still say what this is and why it matters?), the removal test (remove it: does the experience feel diminished or does nobody notice?) and the context test (does this fit THIS product and audience?).

## Quiet and distill requests

Quieter means refined, not generic: reduce saturation (about 70 to 85 percent), fewer hues, flatter surfaces, motion distances of 10 to 20 pt instead of 40, ease-out only; restraint still needs a point of view. Distill means one primary action, one family with three or four sizes, one or two colors plus neutrals, no card inside a card, one obvious next step, and shorter copy that cuts filler, not meaning.
