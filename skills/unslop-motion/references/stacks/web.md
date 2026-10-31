# Web: motion tokens and recipes (CSS first)

The numbers are in `../tokens.md`; this file is their web form. CSS has no springs, so web motion is the three curves plus durations for almost everything, and a generated `linear()` easing for the rare interruptible physical feel. Prefer CSS over JavaScript animation; reach for the Web Animations API when a value is only known at runtime.

## Tokens

```css
:root {
  --ease-out: cubic-bezier(0.23, 1, 0.32, 1);      /* enter, exit, respond to input: the default */
  --ease-move: cubic-bezier(0.77, 0, 0.175, 1);    /* an element moving or morphing on screen */
  --ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);   /* sheets and drawers */

  --dur-press: 120ms; --dur-fast: 160ms; --dur-base: 200ms; --dur-slow: 300ms;
  --dur-enter: 360ms; --dur-exit: 250ms; --dur-reveal: 700ms;
  --stagger: 50ms;
  --rise: 8px; --press-scale: 0.97; --enter-scale: 0.95;
}
@media (prefers-reduced-motion: reduce) {
  :root { --dur-press: 0ms; --dur-fast: 0ms; --dur-base: 0ms; --dur-slow: 0ms; --dur-enter: 0ms; --dur-exit: 0ms; --dur-reveal: 0ms; --stagger: 0ms; --rise: 0px; }
}
```

Reduced motion is gentler, not necessarily zero: keep opacity and color changes short (about 100 ms) and drop movement, scale and parallax. Zeroing every duration is the simplest correct fallback; fade-only is the better one where a state change would otherwise be invisible.

## Press feedback

```css
.pressable { transition: transform var(--dur-press) var(--ease-out), opacity var(--dur-press) var(--ease-out); }
.pressable:active { transform: scale(var(--press-scale)); }
@media (prefers-reduced-motion: reduce) { .pressable:active { transform: none; opacity: 0.7; } }
@media (hover: hover) { .pressable:hover { opacity: 0.92; } }   /* hover is pointer-only, never the only affordance */
```

Never `transition: all`. Name the properties; only `transform` and `opacity` for anything that animates often.

## Entrance (one per screen, fade and rise, small stagger)

```css
@keyframes rise { from { opacity: 0; transform: translateY(var(--rise)); } to { opacity: 1; transform: none; } }
.enter { animation: rise var(--dur-enter) var(--ease-out) both; animation-delay: calc(var(--i, 0) * var(--stagger)); }
```

Set `style="--i: 0|1|2"` per item, six at most; none for long lists. Entrance runs once: add the class on first render, not on every re-render. The element is born in its final layout (no size animation).

## Element appearing, leaving, or changing display

```css
.panel { transition: opacity var(--dur-base) var(--ease-out), transform var(--dur-base) var(--ease-out), display var(--dur-base) allow-discrete, overlay var(--dur-base) allow-discrete; }
.panel { @starting-style { opacity: 0; transform: scale(var(--enter-scale)); } }
.panel[hidden] { opacity: 0; transform: scale(var(--enter-scale)); }
```

`@starting-style` and `allow-discrete` are current in Chromium, Safari and Firefox; provide an instant fallback (no animation) where unsupported. A native `dialog` animates the same way with `dialog[open]` plus `@starting-style`.

## Spring feel with `linear()` (the one place you need a spring)

```js
// Returns a CSS linear() easing that approximates spring(response seconds, damping ratio), plus its duration in ms.
export function springEasing(response, ratio, points = 40) {
  const w = (2 * Math.PI) / response, z = ratio;
  const x = (t) => {
    if (z >= 1) return 1 - Math.exp(-w * t) * (1 + w * t);
    const wd = w * Math.sqrt(1 - z * z);
    return 1 - Math.exp(-z * w * t) * (Math.cos(wd * t) + ((z * w) / wd) * Math.sin(wd * t));
  };
  let T = response; while (Math.abs(1 - x(T)) > 0.001 && T < 10) T += 0.02;   // time to settle within 0.1%
  const stops = Array.from({ length: points + 1 }, (_, i) => +x((i / points) * T).toFixed(4));
  return { easing: `linear(${stops.join(', ')})`, duration: Math.round(T * 1000) };
}
// el.animate({ transform: ['scale(0.97)', 'scale(1)'] }, { ...springEasing(0.3, 0.6) , duration })
```

Use it for a released drag or a toggle; everything that is a plain state change stays on `--ease-out`. The easing overshoots, so animate `transform`, never `width` or `height`. A spring never has a fixed duration: if something must end by a deadline, use the curve.

## Interruptible gestures

Use Pointer Events with `touch-action` set on the draggable (`touch-action: none` or `pan-y`), update `transform` in `requestAnimationFrame`, and on release start a Web Animation from the current transform. Never lock input during an animation; retarget from the current value.

## Passages between views

- **Same-document transitions:** `document.startViewTransition(() => update())` with `::view-transition-old/new` timing from the tokens (exit about 150 ms, enter about 210 ms delayed by the exit, shared move about 400 ms). Fall back to the plain update where unsupported.
- **Multi-page:** `@view-transition { navigation: auto; }` for same-origin navigations; keep the header anchored (give it a `view-transition-name` so it does not slide).
- A reshuffle in place (list reorder, card changing column) is a layout animation (FLIP with the Web Animations API or `view-transition-name` per item), not a page transition.

## Loading: the anti-flicker pair

```js
// Show a loader only if the wait passes 300 ms; once shown keep it at least 500 ms.
export function delayedLoader(show, hide, { delay = 300, minVisible = 500 } = {}) {
  let timer = null, shownAt = 0;
  return {
    start() { timer = setTimeout(() => { shownAt = performance.now(); show(); timer = null; }, delay); },
    stop() {
      if (timer) { clearTimeout(timer); timer = null; return; }          // finished before the delay: nothing ever showed
      const left = Math.max(0, minVisible - (performance.now() - shownAt));
      setTimeout(hide, left);
    },
  };
}
```

Skeletons use the final layout; shimmer is `linear`, 1.2 to 1.6 s, a transform on a pseudo-element (never repainting a background each frame), and a static tint under reduced motion. See `../waiting.md`.

## Haptics

The web has almost none. `navigator.vibrate` is not available in iOS Safari. In iOS Safari 17.4 and later, an `<input type="checkbox" switch>` gives the system toggle haptic with no code. Do not fake haptics with sound or vibration patterns.

## Cheap properties and lifecycle

Animate `transform`, `opacity` and (sparingly) `filter`; avoid animating layout properties (`width`, `height`, `top`, `left`, `margin`) and large `backdrop-filter` blurs. `will-change` only on the element about to move, removed after. Cancel animations and timers on unmount (React: clean up effects; never start an animation from render). Check in DevTools Performance with CPU throttled 4x.

## Check

Slow-motion: DevTools Animations panel at 10 percent speed, or temporarily multiply the duration tokens by 4 and capture a mid-transition frame. Reduced motion: emulate `prefers-reduced-motion` in DevTools Rendering and verify nothing travels. Never validate an animation by loading the page already in its end state.
