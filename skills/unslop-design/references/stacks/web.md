# Web stack (HTML, CSS, React, Tailwind)

Code for the web layer (`platforms/web.md`). The CSS here is stack-neutral: it works in plain HTML, React, Vue, Svelte and, with config, Tailwind. Run and checked in Chrome at 320 to 1280 px, light and dark, reduced motion and by keyboard in the Tidewatch web example (`examples/tidewatch-web`).

## Tokens as custom properties

```css
:root {
  color-scheme: light dark;

  /* spacing: 4px grid */
  --s4: 0.25rem; --s8: 0.5rem; --s12: 0.75rem; --s16: 1rem; --s20: 1.25rem;
  --s24: 1.5rem; --s32: 2rem; --s40: 2.5rem; --s48: 3rem; --s64: 4rem;

  /* color: neutrals + ONE accent, both schemes in one declaration */
  --page: light-dark(#f2f2f7, #000000);
  --card: light-dark(#ffffff, #1c1c1e);
  --text: light-dark(#111114, #f2f2f7);
  --text-2: light-dark(#5b5b63, #a1a1a6);
  --text-3: light-dark(#8a8a92, #7a7a80);
  --hairline: light-dark(rgb(0 0 0 / 0.12), rgb(255 255 255 / 0.16));
  --accent: light-dark(#c2410c, #ff8a4c);   /* replace with the Direction's accent */

  /* type */
  --font: system-ui, -apple-system, "SF Pro Text", "Segoe UI", Roboto, sans-serif;
  --fs-footnote: 0.8125rem; --fs-body: 1.0625rem; --fs-title: 1.375rem; --fs-display: clamp(2rem, 1.4rem + 2.6vw, 3.25rem);

  /* radius, depth */
  --r-row: 0.75rem; --r-card: 1.25rem;

  /* motion: see unslop-motion/references/stacks/web.md for the full set */
}
body { margin: 0; font: var(--fs-body)/1.5 var(--font); color: var(--text); background: var(--page); }
.num { font-variant-numeric: tabular-nums; }
h1, h2, h3 { text-wrap: balance; }
p { text-wrap: pretty; max-width: 65ch; }
```

Resolve color per scheme with `light-dark()` (supported in all current browsers) or a `prefers-color-scheme` media query; never cache one scheme's value in JS. Tailwind: map these to theme variables in the config and delete the default palette from use so `indigo-500` cannot sneak back.

## Focus, hover, pointer

```css
:where(a, button, input, select, textarea, summary, [tabindex]):focus-visible {
  outline: 2px solid var(--accent); outline-offset: 2px; border-radius: 4px;
}
button, [role="button"] { min-block-size: 2.75rem; min-inline-size: 2.75rem; }   /* 44px on touch-first screens */
@media (hover: hover) { .row:hover { background: color-mix(in srgb, var(--text) 5%, transparent); } }
@media (prefers-contrast: more) { :root { --hairline: currentColor; } }
@media (forced-colors: active) { .chip { border: 1px solid CanvasText; } }
```

## Surfaces without slop

```css
.card { background: var(--card); border-radius: var(--r-card); border: 1px solid var(--hairline); padding: var(--s16); }
/* depth on dark = surface steps + hairline; one floating element may take a neutral soft shadow */
.floating { box-shadow: 0 8px 24px rgb(0 0 0 / 0.08); }
@media (prefers-reduced-transparency: reduce) { .frosted { backdrop-filter: none; background: var(--card); } }
```

Nested radius: inner radius = outer radius minus the padding between them (`calc(var(--r-card) - var(--s16))`, never below 4 px). `corner-shape: squircle` exists in newer Chromium only; treat it as an enhancement, never a requirement.

## Regular width: restructure, do not stretch

```html
<div class="shell"><main class="today">...</main></div>
```
```css
.shell { container-type: inline-size; }                       /* the container is the PARENT of what it restyles */
.today { display: grid; grid-template-columns: minmax(0, 1fr); gap: var(--s24); padding: var(--s16); max-inline-size: 72rem; margin-inline: auto; }
@container (min-width: 44rem) { .today { grid-template-columns: 22rem minmax(0, 1fr); align-items: start; } }
```

Two traps found in testing: a container query cannot style its own container (put `container-type` on a wrapper, or the query silently does nothing), and a bare `1fr` grid track cannot shrink below its content (an SVG chart wider than the phone pushed the whole page past the viewport); use `minmax(0, 1fr)` and `min-inline-size: 0` on the item.

Drive structure from the container or viewport width, not user-agent sniffing. A mobile screen centred in a wide window is the failure; so is a desktop table crushed into 390 px. At narrow widths a table becomes a list of labelled rows, not a horizontal scroll.

## React specifics

- One component per role (`Button`, `Row`, `Card`), parameterised; no per-screen copies. Search the project for an existing design-system component before writing one.
- Real elements: `<button type="button">`, `<a href>`, `<label htmlFor>`, `<dialog>`; never `onClick` on a `div`.
- State of data is a sealed union (`loading | empty | error | ready`), rendered as four designed states; error is never rendered as empty.
- Images: `<img width height alt>`; hero with `fetchpriority="high"`, below-the-fold with `loading="lazy"`.
- Respect user settings in JS through media queries (`matchMedia('(prefers-reduced-motion: reduce)')`), not a stored toggle.
- Charts: SVG with `role="img"` and an `aria-label` that states the finding ("Tide today: high 1.9 m at 02:14, low 0.4 m at 08:26"), colors from tokens, not a library default palette.

## Choices as a native radio group

A list of options where one is selected is a `fieldset` with a `legend` and `input type="radio"` rows (visually hidden input, styled `label`, `:has(input:checked)` for the selected look). Arrow keys, one tab stop, announcements and form semantics come free; a `div` with `onClick` has none of them. Dead links (`href="#"`) in a demo nav are a defect: point to in-page anchors or leave the item out.

## Charts in SVG

Render to the container's real pixel width (read `clientWidth`, redraw on `ResizeObserver` only when the width changes) so labels stay at their real size instead of scaling with a `viewBox`. Update a selection (a highlighted window) by changing style properties on the existing element so it transitions in place; rebuilding the SVG kills the transition and replays the reveal. Give labels a `paint-order: stroke` halo in the card color so they never sit unreadably on a band. Draw highlight bands after the area fill and before the curve, or the fill muddies their color.

## Verify

Run in a real browser (`unslop-review/references/stacks/web.md`): the page at five widths, light and dark, reduced motion, 200 percent zoom, keyboard only.
