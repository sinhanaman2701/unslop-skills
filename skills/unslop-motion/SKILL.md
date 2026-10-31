---
name: unslop-motion
description: Use when adding or fixing animation, transitions, gestures, press feedback, haptics, or loading and entrance behavior in an iOS app (Flutter, React Native, SwiftUI) or on the web, or when existing motion feels bouncy, janky, amateur, laggy, overdone, or everything moves at once.
license: MIT
---

# Unslop Motion (iOS-first mobile, and web)

Good motion is barely noticed. It explains where something came from, what changed, or what was touched, and it answers the finger inside a frame budget. Slop motion is amplitude mistaken for quality: bounce everywhere, everything entering at once, loops on things that are not live.

**Core principle.** Ask first whether it should move at all. Then use one physics set, three curves and a few durations for the whole app (`references/tokens.md`), and reuse them. Search the project for an existing motion token file first and extend it; two sources of truth drift.

Built from the unslop motion pass (CC BY 4.0, Damir Sokolovsky), visant-motion and visant-refine (MIT, Visant; principles from Emil Kowalski and Apple's *Designing Fluid Interfaces*), Impeccable (Apache-2.0), and swiftui-microinteractions (MIT, Vishal Paliwal), translated to Flutter, React Native and the web. See `references/credits.md`.

## Step zero: stack

Detect from the project and say which you picked: `pubspec.yaml` is Flutter (`references/stacks/flutter.md`, then `flutter-recipes.md` and `flutter-patterns.md`); `package.json` with `react-native` or `expo` is React Native (`stacks/react-native.md`); Swift sources are SwiftUI (`stacks/swiftui.md`); HTML, CSS or a web framework is web (`stacks/web.md`). The principles, tokens and archetypes below are identical on every stack; only the code differs.

## When to use

- A tap, drag, toggle, sheet, list, number change, loading, success or passage between screens needs motion or haptics
- Existing animation feels bouncy, amateur, stuck, janky, or too busy
- Translating a SwiftUI or UIKit interaction into another stack

Not for: static layout, color, type or copy (**unslop-design**); a scored pre-PR audit (**unslop-review**).

## Reference map

| Need | Read |
| --- | --- |
| Tokens (curves, durations, springs, wait thresholds), which tool, archetype defaults | `references/tokens.md` |
| Code for the tokens, recipes and checks, per stack | `references/stacks/<stack>.md` |
| Flutter recipes (press, haptics, entrance, count-up, rubber band, momentum) and patterns (carousels, decks, toasts, tab indicator, tours, gauges, loaders) | `references/stacks/flutter-recipes.md`, `flutter-patterns.md` |
| Loading, skeletons, errors after a wait (policy) | `references/waiting.md` |
| Push, sheet, tab and shared-element passages | `references/navigation.md` |

## Decide before coding

1. **Should this animate?** Something used a hundred times a day does not. Occasional (a sheet, a toast) gets standard motion; rare (onboarding, a first success) may delight. A work screen does not stage a show.
2. **Is there a native component?** The platform's switches, segmented controls, context menus, sheets and page routes already animate and give haptics correctly. Use them (`stacks/<stack>.md` lists them).
3. **Which archetype?** Pick from the table below; it sets physics and haptics.
4. **What is the one focus of motion?** A screen where a queue ticks, images arrive, a bar fills, a toast slides and an error shakes is five animations competing. Sequence the states (sent, generating, ready) and keep the rest still.
5. **Which variable does it move?** Directing the eye to the number that decides moves decision quality; celebrating a finished action moves retention; decorating a card's entrance moves nothing and still spends the channel.

## Archetypes

| Archetype | Physics | Haptics (mobile) |
| --- | --- | --- |
| Press feedback (buttons, rows) | spring `press`, scale 0.97 (web: `curve`, 120 ms) | none by default |
| Toggle, segmented control | native component; custom: spring `pop` | selection tick on change |
| Drag card (dismiss, reorder) | spring `physics` on release, rubber band while dragging | light on pickup, medium at threshold (rearm on retreat), heavy only for a destructive commit |
| Paging, coverflow | momentum projection, then spring `physics` | selection tick per index |
| Data number change | tween 300 to 400 ms, `curve` | selection tick per discrete step |
| Entrance (one per screen) | fade + 6 to 12 pt rise, 360 ms, stagger 30 to 80 ms, six items max | none |
| Sheet, menu, popover | system presentation | none |
| Glass morph or reshape (iOS) | spring `morph`; static fill while dragging | medium on completion |
| Loading | skeleton of the final shape; progress `linear` | none |
| Success or error | one 200 to 300 ms response (check draws, field shakes) | one notification haptic via a plugin, or none |

On web there are no haptics (`stacks/web.md`): the same archetypes get the visual half only.

## Rules

- **Amplitude.** Cut it in half, then in half again. Press scale 0.97 (icon buttons 0.92); pop 0.96 to 1.04; rotations up to about 12 degrees; no overshoot on things that disappear. Amplitude, not duration, is what reads as amateur.
- **Never scale from 0.** Start entrances at 0.95 plus opacity; nothing appears from nothing.
- **Durations.** Press 120 ms, small popovers 160, menus and cards 200, sheets 300. Anything the finger waits on finishes under 300 ms; above about 400 it feels stuck. Content that arrives (not waiting on a finger) may take 300 to 500 ms. Exit runs about 70 percent of the entrance. Asymmetric timing: slow where the person decides, fast where the system responds.
- **Three curves only** (`curve`, `move`, `drawer`). Never bounce or elastic curves, and never ease-in on UI.
- **Springs only for momentum and gestures** (drag, flick, anything a finger can interrupt). A menu fade uses a duration. Critically damped by default; add bounce only when a flick preceded it.
- **Interruptible.** Retarget from the current value and velocity. Never lock input during an animation. A restarting keyframe animation on rapidly triggered UI is a bug.
- **Born in its best state.** A glow, tilt or perspective that only appears on touch does not exist in a screenshot or a list thumbnail. Start in the hero pose; interaction intensifies, it never reveals.
- **Close the surface first** when the payoff is a row leaving the list: the sheet closing is the exit with weight. One visible exit per surface.
- **No loops** unless the thing is live (recording, syncing, loading). No stagger by index on long lists.
- **One waiting animation per surface**; never let an entrance cost more than the wait (`references/waiting.md`).
- **Reduce Motion is gentler, not off.** When the system setting is on (iOS Reduce Motion, web `prefers-reduced-motion`), drop movement, springs and parallax; keep opacity, color and the result. Increase Contrast and Reduce Transparency get solid surfaces. Where a stack renders a switcher or controller, bypass it rather than setting its duration to zero (a zero-duration controller still runs a frame).
- **Haptics are punctuation** (mobile). Add them for thresholds, commits, discrete scrubs and meaningful toggles; skip them for ambient animation and for every ordinary tap. Success, warning and error notification haptics may need a plugin (check the stack file).
- **Cheap properties.** Animate transform and opacity, not width, height, padding or large blurs every frame. Keep animated or blurred regions isolated.
- **Lifecycle.** Whatever starts an animation or timer cancels it on teardown; nothing starts from render or build; an entrance plays once on mount, not on every re-render.
- **Sound** is motion for the ear and obeys the same rules: only where the person acts, never on hover or ambient, silent under Reduce Motion, never per pixel of a drag. Add only if asked.
- **Delight is earned.** Match the response to the effort and consequence; a routine save should just feel certain. Do not manufacture a celebration for an ordinary tap, and never let a flourish delay the task.

## Designer words to physics

| Says | Means |
| --- | --- |
| snappy, crisp, tight | spring `pop` |
| bouncy, springy | spring `snap` (rare, playful products only) |
| stretchy, rubbery | response 0.4, damping 0.5 |
| soft, floats, melts | spring `morph` |
| stiff, precise, mechanical | spring `stiff` |
| linear, steady | linear easing, for progress only |
| anticipation | 80 ms opposite pre-move of 2 to 4 percent, then the main move |
| follow-through | damping 0.7 to 0.8 so it overshoots slightly and settles |
| stagger | 30 to 80 ms per item, six items max |
| wiggle, shake | 3 cycles of plus or minus 6 pt over 300 ms, on error only |
| pop | scale 0.96 to 1.04 to 1 |

## Writing the code

1. Check the project: search for an existing motion token file, haptics helper or spring definitions; reuse what exists, never redeclare it.
2. Tokens in one file; recipes in the feature that needs them.
3. Before the code, print an `Inferred:` block (vocabulary mapping, archetype, haptics, Reduce Motion fallback) so the user can override.
4. Deliver complete, compilable code for the stack: imports, teardown, no placeholders, no TODO. Run the stack's analyzer or type-checker (`flutter analyze`, `npx tsc --noEmit`, the browser console) and fix what the project's versions reject.
5. **Verify by watching motion, not its end state.** Slow it down (4x) and capture a mid-transition frame; never validate an animation by starting the screen already in its destination state. Then run on a physical device in a release or profile build (mobile): simulator frame times lie, and they say nothing about gestures or haptics. Web: DevTools Performance with CPU throttled.

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Springy overshoot clamped by a bounded controller (Flutter: bounded `AnimationController`) | an unbounded controller |
| State update every frame | the stack's animation primitives (`AnimatedBuilder`, Reanimated shared values, CSS) |
| Haptic firing on every drag tick | gate on crossing, rearm on retreat |
| Threshold haptic that fires once ever | rearm when the value falls back under the line |
| Hover-style grow on a card (mobile) | no hover on touch; use a pressed state (web: only inside `@media (hover: hover)`) |
| Entrance replayed on every re-render | start once on mount |
| Animation that blocks a tap | springs retarget; do not disable hit testing |
| Looping shimmer on headings | static skeleton, or none |
| Exit animation playing behind an open sheet | close the sheet first |
| An in-button spinner on a surface that closes on tap | delete the spinner and its state |
| Two animations for the manual and automatic path | one function, two callers |
| `transition: all` (web) | name the properties |
