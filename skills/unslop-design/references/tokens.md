# Tokens

Starting values for each pass. Numbers are iOS points; on web use the same numbers as px (or divide by 16 for rem), and read `platforms/web.md` and `stacks/web.md` for the web-specific values (focus ring, targets, `light-dark()` colors, fluid type). If the project already has a good system, keep its values and fix how they are used. These are starting points, not a house style; the Direction moves them.

## Spacing scale (pt)

4, 8, 12, 16, 20, 24, 32, 40, 48, 64

- Inside a control: 4 to 12
- Between related items (rows): 0 to 8
- Between groups (label and its list, two cards): 12 to 24
- Between sections: 24 to 40
- Page edge padding: 16 to 20 (follow the system layout margins)
- Row height: 44 default (the minimum tap target), 52 to 60 for two-line rows
- Hero or onboarding: 48 to 64 from the navigation to the headline

## iOS layout metrics

- Navigation bar 44 plus the large-title area; tab bar 49 plus the home-indicator inset (use the system widgets so they stay right)
- Minimum tap target 44 x 44 (Flutter: `kMinInteractiveDimensionCupertino`; web: 24 px minimum by WCAG 2.2, 44 on touch-first screens)
- Stat cards in a row share one height; two per row on phones, numbers only
- Main chart spans the content width and is 200 to 280 tall; a second data block is a list, not another chart

## Text styles (iOS defaults at the default Dynamic Type size)

| Style | Size | Weight | Use |
| --- | --- | --- | --- |
| Large title | 34 | regular/bold per system | top-level screen title |
| Title 1 | 28 | regular | page title |
| Title 2 | 22 | regular | section title |
| Title 3 | 20 | regular | card title |
| Headline | 17 | semibold | row title, button |
| Body | 17 | regular | content |
| Callout | 16 | regular | secondary content |
| Subheadline | 15 | regular | captions with body |
| Footnote | 13 | regular | meta |
| Caption 1 / 2 | 12 / 11 | regular | counts, fine print |

Hero headline on onboarding or marketing screens may go 34 to 48. Sizes scale with Dynamic Type; never hard-code a height that depends on them.

Letter spacing: 0 below 20pt; display text from 34pt may go to -0.02em; small muted text may take +0.01em.

## Neutral colors

Default: system semantic colors on iOS (they adapt to dark mode, increased contrast and elevation); on web the same roles as custom properties with `light-dark()` (`stacks/web.md`).

| Role | Semantic color |
| --- | --- |
| Page | `systemBackground` (grouped screens: `systemGroupedBackground`) |
| Card on page | `secondarySystemGroupedBackground` or `secondarySystemBackground` |
| Raised or input | `tertiarySystemFill` / `tertiarySystemBackground` |
| Hairline | `separator` (or `opaqueSeparator` when it sits on moving content) |
| Text primary / secondary / tertiary | `label` / `secondaryLabel` / `tertiaryLabel` |

Custom ramps only when the Direction needs a tinted world. Keep saturation very low so a surface never reads as a color. Dark, graphite / warm / ink:

| Role | Graphite | Warm | Ink |
| --- | --- | --- | --- |
| Deepest | #0F0F10 | #12110F | #07080D |
| Page | #141415 | #161513 | #0B0D14 |
| Card | #19191B | #1C1A18 | #11141C |
| Raised | #232325 | #262421 | #1A1E28 |
| Primary text | #EDEDED | #EFE9DE | #EEF0F5 |
| Secondary text | #A1A1A6 | #AAA398 | #A3A9B8 |
| Muted | #85858B | #8A847A | #7A8296 |

Light: page #FAFAFA / #F7F4EE / #F5F7FA; card #FFFFFF / #FDFBF7 / #FFFFFF; primary text #171717 / #1F1B16 / #111827. Muted text stays near 4.5:1 and is for meta only.

Semantic: positive #4CC38A dark / #16A34A light; negative #E5484D dark / #DC2626 light.

## Accent

- Keep a real brand color. Hue-to-hue glow gradients are not a brand color.
- Without one, take it from the world: warm worlds amber, coral, ember; cool worlds cobalt, teal, clear blue; natural worlds moss, sage. Avoid the purple-blue family unless the brand is purple.
- Text on the accent reaches 4.5:1.
- The accent covers a few percent of the screen.

## Buttons

- Primary 50 tall on onboarding, 44 elsewhere; side padding 16 to 20.
- Primary on dark: an off-white from the ramp with dark text, or the accent. On light: the primary text color as fill with white text, or the accent.
- Secondary: raised surface with a hairline, primary text.
- One primary per screen. A disabled primary does not exist; explain what is missing instead.

## Type families

On iOS the system font (SF Pro) is the interface family: it gets Dynamic Type, optical sizes and platform feel for free. A brand face belongs in display moments (large headlines, onboarding, paywall) and is bundled with the app (`pubspec.yaml`, app assets or `@font-face`; on web with `font-display: swap`). Another interface family needs a reason no other face could satisfy; "tech wants a mono", "books want a serif" and "it is trending" are not reasons. The usual training-data defaults (Inter used as a display face, Space Grotesk, Plus Jakarta Sans, DM Sans, Outfit, Fraunces, Playfair, Cormorant, Lora, Newsreader, Instrument Sans or Serif, IBM Plex, Geist) are the ones to avoid by reflex. Pair at most one partner with the system face: a mono for figures or IDs, or a display face for large headlines only. Never a display serif on labels or buttons. Judge a face by character, name the character in the Direction, and check it at the largest Dynamic Type size.

## Radius (pt)

| Element | Radius |
| --- | --- |
| Keycap, tag | 4 to 6 |
| Row, input | 10 to 12 |
| Button | 12 to 14, or capsule where the system uses capsules |
| Card | 16 to 20 |
| Sheet, large panel | 20 to 28 |

Nested radius: inner = outer - padding, never below 4. A 20pt card with 8pt padding holds a 12pt item. Use continuous (superellipse) corners.

## Depth

- Dark: surface steps plus a hairline. A pressed or active row may carry a 1px top highlight at white 10 to 12 percent.
- Light: tonal steps (grey page, white cards) instead of shadows between stacked surfaces. A single floating element may take `0 8 24 black 6%`.

## Motion

Values live in **unslop-motion** (`references/tokens.md`). Never repeat them here.
