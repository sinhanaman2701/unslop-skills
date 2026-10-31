# Web conformance

What a fluent web user expects, mapped to checks you can run in a browser. The web has no single native toolkit, so conformance here means three things: the platform's own semantics (HTML, focus, zoom, reading order), the user's settings (color scheme, reduced motion, contrast, text size) and the browser's performance budget. Source rules: WCAG 2.2 AA, web.dev guidance, and the unslop and Impeccable web references. Code for React, CSS and Tailwind: `stacks/web.md`.

The web slop test: would someone who builds for the web trust this page, or does it read as the default AI landing page (hero with a pill, gradient headline, three icon cards, a logo strip, a gradient blob)?

## Structure and navigation (critical)

- **Semantic HTML first.** `button` for actions, `a` for navigation, `nav`, `main`, `header`, `footer`, one `h1`, headings in order. A `div` with an `onClick` is a defect, not a style choice.
- **Navigation shows where you are.** Current page marked (`aria-current="page"`), visible in the nav, not only by color. Five to seven top-level items; more becomes grouping, not a hamburger on desktop. A hamburger is acceptable below a breakpoint when it is a real `button` with an accessible name and `aria-expanded`.
- **A skip link** is the first focusable element on any page with repeated navigation.
- **Back works.** URLs reflect state that matters (filters, tabs, selected record); the browser back button never traps; modals close with Escape and return focus to their trigger.
- **Preserve state** across navigation (scroll, form input, filters); do not reset a form on a validation error.
- **Modals sparingly.** Native `dialog` with a labelled title, a visible close, focus trap and Escape; never a modal as the first answer; never stacked; never an unclosable one.
- **One primary action per view**; secondary quieter; destructive actions name the object and offer undo.

## Layout

- **Content-driven breakpoints**, not device names. Test at 320, 390, 768, 1024, 1440 px wide, plus 200 percent browser zoom (a 640 px viewport) where nothing may overflow or hide. WCAG 1.4.10 reflow at 320 CSS px: no horizontal scroll for content.
- **Measure.** Prose 45 to 75 characters (`max-width: 65ch`); a headline never runs the full width of a 1440 px screen.
- **A real layout system:** 4 px grid, a spacing scale as custom properties (`tokens.md`), `gap` instead of margin hacks, `min()`/`clamp()` for fluid type and padding, container queries for components that live in different widths.
- **No layout shift.** Images and embeds carry `width`/`height` or `aspect-ratio`; fonts do not reflow the page (`font-display: swap`, matched fallback metrics); loaded content does not push what the user was reading.
- **Viewport units on mobile browsers:** `100dvh`, not `100vh`; respect `env(safe-area-inset-*)` when the page fills the screen on a notched phone.
- **Pointer and touch.** Hover reveals nothing the touch user needs; wrap hover-only styles in `@media (hover: hover)`. Targets at least 24 x 24 CSS px (WCAG 2.2 AA minimum) and 44 x 44 for touch-primary screens, with space between neighbours. Inputs use at least 16 px type so iOS Safari does not zoom on focus.

## Typography and color

- **System font stack or one real brand face** (`font-family: system-ui, -apple-system, ...`). A web font is a cost: two families and four weights at most, `font-display: swap`, preloaded. The reflex families listed in `tokens.md` are the ones to avoid by reflex.
- **Type in `rem`** so browser text size settings work; never `px` on body copy; `text-wrap: balance` on headlines, `pretty` on paragraphs; `font-variant-numeric: tabular-nums` for figures.
- **Scale and hierarchy** as in `tokens.md` (steps of 1.125 to 1.25), line height at least 1.5 for body, 1.1 to 1.25 for display.
- **Color scheme.** Support both: `color-scheme: light dark` and tokens through `light-dark()` or `prefers-color-scheme`; dark is designed, not inverted. Text contrast 4.5:1 (3:1 for large text and UI boundaries). Honor `prefers-contrast: more` and `forced-colors: active` (never rely on a background color alone to show a border or a focus ring).
- **One accent**; three text roles; no gradient text; no colored glows (the same rules as every platform: `passes.md`).

## Accessibility (critical)

- **Keyboard:** everything reachable and operable; logical tab order (DOM order, no positive `tabindex`); visible `:focus-visible` ring with 3:1 contrast against its surroundings; custom widgets follow the ARIA Authoring Practices pattern, or use the native element.
- **Names and roles:** every control has an accessible name (a visible label, or `aria-label` for icon-only); `alt` on content images, `alt=""` on decoration; ARIA only where HTML has no element for it.
- **Forms:** a real `label` per field, `autocomplete` and `inputmode` set, errors announced (`aria-describedby`, `role="alert"` on submit), an error summary that links to fields, required marked once; never disable the submit button to explain what is missing.
- **Motion:** `prefers-reduced-motion: reduce` replaces movement with a fade or nothing; no auto-playing carousel; nothing flashes more than three times per second.
- **Zoom and text size:** `meta viewport` never disables zoom (`user-scalable=no` is a defect); layout reflows at 200 percent text size.
- **Status and live regions:** loading and result changes reach screen readers (`aria-live="polite"`, `role="status"`).

## Performance as design

A slow page is an ugly page. Largest content paints under 2.5 s, interactions respond under 200 ms, no layout shift. Ship images in the size shown (`srcset`, `sizes`, modern formats, `loading="lazy"` below the fold, never on the hero), avoid large blurs and `backdrop-filter` on scrolling content, animate `transform` and `opacity` only, and keep third-party scripts out of the critical path.

## Web slop tells (in addition to `signs.md`)

- Hero: a small pill or tracked-caps eyebrow, a gradient headline, one line of subcopy, two buttons, a floating mock card, a gradient blob. Replace with the page's single claim in plain words and a real product visual.
- Three equal feature cards each with a rounded-square icon, a bold two-word title and one line; a bento grid of equal tiles; a logo strip of unverified "trusted by" brands; fabricated testimonials or star ratings; "10,000+ users" with no source.
- Glassmorphism cards on a gradient background; neon on near-black by reflex; dot-grid backgrounds; noise textures; floating emoji; sparkle icons next to everything "AI".
- Defaults left in place: a framework's stock palette (indigo or violet 500 to 600), shadcn or Material defaults untouched, `rounded-2xl shadow-lg` on every box, Inter as both display and body.
- Motion: everything fades up on scroll; marquees of nothing; parallax on content; hover lifts on every card.
- Footer and chrome: a four-column footer of links nobody needs, a cookie banner covering the first screen, a sticky header taller than it needs to be.

## Port from mobile or from a template

A page ported from a mobile app keeps a 390 px column in a 1440 px window and a bottom tab bar on desktop: restructure for the width (`stacks/web.md`, "Regular width"). A page made from a template inherits its copy and structure: run the swap test (replace the product name with a competitor's).

## Checks you can actually run

Keyboard-only pass through the whole flow; 200 percent zoom; reduced-motion on; dark scheme on; a throttled network and CPU run; an axe or Lighthouse run for the mechanical half (`unslop-review/references/stacks/web.md`). Automated tools find about a third of accessibility defects; the keyboard pass finds most of the rest.
