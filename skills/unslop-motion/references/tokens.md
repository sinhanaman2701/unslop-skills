# Motion tokens (every stack)

The SwiftUI-style `spring(response, dampingFraction)` is converted with stiffness = (2 pi / response)^2, mass 1, damping ratio = dampingFraction. The presets keep the feel of the SwiftUI skill this was translated from.

Tokens (names used across the skill; each stack file gives them in code):

| Token | Value |
| --- | --- |
| `curve` (enter, exit, respond to input; default) | cubic-bezier(0.23, 1, 0.32, 1) |
| `move` (an element moving or morphing on screen) | cubic-bezier(0.77, 0, 0.175, 1) |
| `drawer` (sheets, drawers, iOS-like) | cubic-bezier(0.32, 0.72, 0, 1) |
| `press` / `fast` / `base` / `slow` | 120 / 160 / 200 / 300 ms |
| `enter` / `exit` | 360 ms (300 to 500) / 250 ms (about 70 percent of enter) |
| `reveal` (the one authored moment per screen, such as a chart drawing in) | 700 ms |
| `stagger` | 50 ms (30 to 80), six items maximum |
| `riseDistance` | 8 pt or px (6 to 12) |
| `pressScale` | 0.97 (icon buttons 0.92, wide rows 0.985) |
| `enterScale` | 0.95; never scale from 0 |
| Wait thresholds | instant 100 ms; loader delay 300 ms; loader minimum visible 500 ms; narrate the step at 5 s; offer an escape at 10 s |

Spring presets are `spring(response seconds, damping ratio)` (SwiftUI convention): snap 0.35/0.50 (playful, rare), pop 0.35/0.60 (toggles, chips), settle 0.40/0.65 (small cards), physics 0.45/0.70 (dragged card released), morph 0.60/0.80 (reshape), dial 0.30/0.70 (scrubbing, numbers), press 0.30/0.60, enter 0.50/0.82 (content assembling), stiff (stiffness 220, damping 22; mechanical), move 0.4/1.0 (critically damped reposition), rotate 0.4/0.8, sheet 0.3/0.8. Conversion to physics: stiffness = (2 pi / response)^2, mass 1, damping = 2 * ratio * sqrt(stiffness).

Where each stack puts them: Flutter `stacks/flutter.md`, React Native `stacks/react-native.md`, web `stacks/web.md` (CSS has no springs; it uses the three curves plus a `linear()` approximation), SwiftUI `stacks/swiftui.md`.

(cubic-bezier(0.22, 1, 0.36, 1) from the unslop source is an equivalent ease-out; keep exactly one in the app.)

Computed values for reference (stiffness / damping at mass 1):

| Preset | Response | Damping ratio | Stiffness | Damping coefficient |
| --- | --- | --- | --- | --- |
| snap | 0.35 | 0.50 | 322.3 | 17.95 |
| pop | 0.35 | 0.60 | 322.3 | 21.54 |
| settle | 0.40 | 0.65 | 246.7 | 20.42 |
| physics | 0.45 | 0.70 | 195.0 | 19.55 |
| morph | 0.60 | 0.80 | 109.7 | 16.76 |
| dial | 0.30 | 0.70 | 438.6 | 29.32 |
| press | 0.30 | 0.60 | 438.6 | 25.13 |
| enter | 0.50 | 0.82 | 157.9 | 20.61 |

Never write a bare spring with guessed numbers. If the user supplies values, use them as given.

## Which tool

| Situation | Use |
| --- | --- |
| Enter or exit of a UI element | `curve`, tween, base duration |
| An element moving or morphing on screen | `move` |
| Sheet or drawer | system presentation; custom: `drawer` or spring `sheet` |
| Hover or color change | `ease`, 100 to 150 ms |
| Constant motion (progress, shimmer) | `linear` |
| Drag with momentum, flick, anything interruptible by a finger | a spring |
| A menu fade | a duration, never a spring |

Never `ease-in` on UI (it delays the first movement, the moment the user is watching). The one exception is the outgoing page of a route passage, where nothing waits on it.

Name presets by how they move when you expose them to a designer: "Snappy: settles fast, no overshoot", "Gentle", "Bouncy". The numbers are the implementation. Three ways to specify the same motion exist (easing curve; time = response and damping; physics = stiffness and damping); a tweak panel shows the mode above the curve.

## Archetype defaults

| Archetype | Default |
| --- | --- |
| Press | spring `press`, `pressScale` |
| Toggle | spring `pop` |
| Drag card release | spring `physics` |
| Sheet-like reveal | spring `sheet` or `settle` |
| Numbers | spring `dial` or a tween with `curve` |
| Reshape | spring `morph` |
| Loading, progress | `linear`; never a spring (loops look jittery) |

## Perceived timing

- 100 ms feels instant; 300 ms is the ceiling for a response to a touch; above about 400 ms an interactive element feels stuck.
- Springs have no fixed duration. If a transition must end by a deadline (a route push), use a tween with `curve`.
- A spring that visibly bounces three times is amateur. If you can see it settling, raise damping.
- Asymmetric timing: slow where the person decides (a hold-to-delete of 1 to 2 s), fast where the system responds (release in 200 ms).
- UI animation never needs bounce or elastic curves.
