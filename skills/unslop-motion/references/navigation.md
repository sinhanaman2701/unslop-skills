# Navigation and passage between screens

A control answers a tap in under 300 ms. A passage between screens is a different animal: it may be longer and more deliberate, and it is where an app stops feeling like a web page. Sources: visant-motion section 5, Impeccable's iOS rules, the HIG rules. The default is the platform's own navigation; the tool column below names the Flutter, React Native and web equivalents.

## Default: let the system do it

- **Push and pop** use the platform's navigation (slide, parallax, swipe-back): Flutter `CupertinoPageRoute`, React Native `native-stack`, SwiftUI `NavigationStack`. Never disable or overlay the left-edge back gesture; never block back (Flutter `PopScope(canPop: false)`) without a real reason (unsaved data) and an explicit confirm. On web the browser's back button is the model: URLs carry state, and a transition never traps back.
- **Sheets** rise from the bottom and dismiss by reversing the entrance. Use the system presentation (Flutter `showCupertinoModalPopup` or the Cupertino sheet route; React Native `presentation: 'modal'` or `'formSheet'`; SwiftUI `.sheet`; web a native `dialog`). Always a visible dismiss (Cancel or Done) plus swipe down; never stack modals on modals.
- **Tab switches** are not hierarchy: cross-fade the content (`base` duration, no slide; Flutter `AnimatedSwitcher`), keep the tab bar, and restore each tab's scroll and state.
- Never fight the navigation model with a custom transition that slides sideways where the system would push. The user's thumb already knows where "back" is.

## Custom passages: pick the claim you are making

| Pattern | What it claims | Tool (Flutter / web) | Use when |
| --- | --- | --- | --- |
| Shared-element morph | "same object, going deeper" | `Hero` (matching tags) / View Transitions with `view-transition-name` | thumbnail to detail, row to record |
| Reveal on the destination | "the data arrived" | skeleton to content cross-fade (both) | route-scale version of the skeleton handoff |
| Directional slide | "forward / back" | the system push / the browser's own navigation | a real hierarchy exists |
| Same-place cross-fade | "same place, different content" | `AnimatedSwitcher` / a CSS opacity transition | tabs, filters, period switches |

A slide that says "forward" on a sideways move is worse than no animation: the passage must make a true claim.

## Numbers for custom passages

- Exit about 150 ms, enter about 210 ms and delayed by the exit, shared move about 400 ms. The old view leaves fast because it already lost the argument; the new one arrives calmly enough to read. This asymmetry is the point.
- `ease-in` is acceptable only on the outgoing page (nothing waits on it); everything else is `curve` or `move`.
- A small blur (about 3 pt) during a shared-element morph can hide interpolation smear; keep blur under 20 and bounded to the morphing region.
- Anchor something: the navigation bar or the tab bar must not slide, or the user reads "the whole screen jumped" instead of "the content changed".
- Do not make something the user may tap repeatedly a shared element (Flutter `Hero`); an element in flight swallows hits.
- A morph only pairs when the destination renders in the same frame (prefetched data). If it shows a skeleton first, let the content play its normal entrance instead; do not hang comprehension on the morph.
- A reshuffle in place (a row reordering, a card changing column) is not a navigation: use layout animation (Flutter `AnimatedList` or `AnimatedPositioned` with transforms; web FLIP), not a route transition. Rule of thumb: route changed means shared element; layout reshuffled in place means layout animation.

## Close the surface first

When completing an item from a sheet, and the payoff is the row collapsing out of the list behind it, close the sheet first. The sheet closing is the exit with weight; the row then collapses in view. Playing the row's exit behind an open sheet hides the animation you paid for and holds the sheet open for its duration. One visible exit per surface.

## Reduce Motion

The system Reduce Motion setting is on (Flutter `MediaQuery.disableAnimationsOf(context)`; web `prefers-reduced-motion`): replace slides, parallax and large movements with a cross-fade or an instant cut. The result still happens. Directional slides are the biggest motion-sickness trigger, so this fallback is the one you cannot skip.
