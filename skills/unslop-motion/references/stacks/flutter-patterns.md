# Interaction patterns (Flutter translation)

Translated from the SwiftUI skill's pattern sections (every section read; ones with no Flutter equivalent are noted at the end). Numbers come from that skill's tested builds. Use them as starting values and look at the result. Code is sketch-level and was not compiled; run `flutter analyze`.

## Drag, paging and momentum

- **Page on predicted rest, not raw distance.** A slow short drag should not page; a fast flick should, even if the finger barely moved. Compute where the flick will rest and compare that to a threshold (about 52 pt in the source):

```dart
/// Where a flick comes to rest (UIScrollView-style deceleration, d = 0.998).
double projectedEnd(double position, double velocityPxPerSec, {double d = 0.998}) =>
    position + (velocityPxPerSec / 1000) * d / (1 - d);
```

  Then snap to the nearest target. Decompose 2D motion into independent X and Y springs. Blend velocity on a reversal so it does not hit a brick wall. Respond on touch-down, track 1:1 with the finger, and apply a resistance factor (about 0.5) to a drag that must feel weighty.
- **Rubber-band at limits**, never a hard stop (`rubberBand` in `flutter-recipes.md`).
- **Haptic on a discrete index change** is `selectionClick`, once per item boundary crossed in either direction. Compute it by rounding the position to the nearest index and diffing against the last index you ticked, not with a pixel threshold, so it works at any item spacing. A boundary (overscroll) thud fires once per excursion: set a flag the first frame the offset passes the end, reset it when the next drag begins, or it fires every frame.
- **Do not nest drag in drag.** A child draggable inside a row that is already draggable or long-pressable makes the recognizers fight, and scoping the child to a grip handle does not fix it. Reorder with discrete tap controls (up and down buttons that fire on tap) and persist the new order positionally.

## Coverflow and fans

Drive every transform off one signed distance that blends the live drag in, instead of a selected / not-selected boolean:

```dart
double effectiveDistance(int i, double selectedIndex, double dragOffset, double cardWidth) =>
    (i - selectedIndex) - dragOffset / cardWidth; // fractional cards moved

double scaleFor(double d)   => math.max(0.82, 1.0 - 0.12 * d.abs());
double rotationDeg(double d) => d.clamp(-2.0, 2.0) * 7;     // capped at +-14 degrees
double yOffsetFor(double d) => d.abs() * 18;
double opacityFor(double d) => math.max(0.0, 1.0 - 0.28 * d.abs());
double blurFor(double d)    => math.min(4.0, d.abs() * 2);  // cheap depth of field
```

Clamp rotation, scale and opacity to a floor so distant cards stay small, dim and blurred instead of flipping or inverting. z-order by proximity. The two sides may respond differently (ahead fans flatter, behind stands upright): branch on the sign of the distance. Use `PageController.page` as the live value, and `selectionClick` per index change.

## Selection-synced backdrop

A full-bleed blurred backdrop that matches the selected card: stack all candidate images and cross-fade each one's opacity (`AnimatedOpacity`, about 550 ms); never swap the image widget in the tree, which restarts the load and cannot cross-fade. Apply the blur and the saturation boost once to the whole stack (`ImageFiltered`), not per image. Use a top and bottom scrim (black 55 percent to clear to black 70 percent) when text sits over the photo for its whole height. When the backdrop should only fill the top and hand off to a solid card below, mask the image with a white-to-clear gradient (`ShaderMask`) over a solid color instead of a scrim: a mask reveals the layer behind, a scrim only dims.

## Page dots and detail text

Variable-width dots: the active dot stretches from 7 to 22 pt into a capsule on a `Springs.pop`-like curve; a color-only dot indicator looks dated. For text that follows a selection, cross-fade keyed to the item's own id (`AnimatedSwitcher` with `ValueKey(item.id)`); keying to the displayed string silently skips the fade when two items share it.

## Tab bar (when you draw your own)

Prefer `CupertinoTabBar` (it keeps system metrics). When drawing a floating bar: heights 49 pt (icons only) or about 68 pt (icon and label); icon 22 pt, semibold when selected and regular otherwise; label 10 to 11 pt; selected indicator fill white at 14 percent, inset 5 pt, radius equal to the outer radius minus 5, width exactly bar width divided by tab count. A content-driven alternative: only the selected tab shows its label so the capsule autosizes with no indicator math; it suits a floating bar over content, not a fixed-grid bar. Swap an icon on a toggle (menu to close, play to pause) with a cross-fade plus small scale on the same button; never hide the button to reveal a separate close button.

## Stacked cards and decks

- **Notification stack:** front card at full size, older cards peek behind. Per depth: y offset 16 pt, scale `max(0.88, 1 - 0.06 * depth)`, opacity falling about 0.22 per level with only about three visible. Tap expands to a list; only the front card swipes away (rubber-band, light haptic on pickup, past about 120 pt remove and heavy haptic, else spring back); cap the count so the oldest drops off the back. The collapsed deck is one tap target; cards beneath ignore hits until expanded.
- **Auto-advancing deck (swipe or timer, infinite wrap):** one `advance()` function called by both the swipe and the timer so the paths cannot drift. Wrap with `(i - index + count) % count`. The critical trap: render the discarded card as an independent overlay outside the stack, so bumping the index reshuffles the stack immediately instead of fighting the exit. Use two different durations on purpose: the stack reshuffle fast (about 550 ms), the exiting card's fall slower (about 850 ms). A progressive stepped offset (18, 15, 12, 9, 9) reads more physical than a constant step. Do not double-fire when a swipe is already in flight.

## Toasts and status banners

One toast surface for every status (neutral surface, identical shape); put the status in the icon, not the fill, or one toast reads as a solid slab while the neutral ones look different. Anchor to the safe-area top with a small pad rather than a fixed offset (a fixed pad lands under the Dynamic Island). Auto-dismiss with a token (clear only if the toast is still the one you showed, so a newer toast is not cut short), about 2.5 s, and animate in and out with a short slide plus fade. Pair with the haptic ladder: a success, warning or error notification haptic (needs a plugin; core Flutter has none) for those kinds, `lightImpact` for neutral info.

## Coach-mark tour

One overlay for the whole tour; a step change is a layout change. Presenting an overlay per step makes every Next read as a screen dismissing. Animate the cutout's rect from control to control (`Springs` around 0.5 response, 0.86 damping) and cross-fade the bubble (re-key it per step); do not spring the bubble's position or the text smears. Leave by fading out, never by a system dismissal. Collect target rects in global coordinates at the screen root (a tab bar or button outside the scroll view must be seen); read the safe-area insets separately. Put the bubble on the roomier side measured inside the safe area, clamp x to a 16 pt margin, and point the arrow from where the target's center lands on the bubble. A target that is not laid out is skipped, never spotlighted at zero size. The scrim does nothing on tap; a hit area over the cutout runs the control's real action after the fade. End tour is the quiet action. Run the tour only while its host screen is frontmost.

## Data and gauges

- **Animated proportional bar:** a track plus a fill that grows from 0 on first appear and re-springs on data change; animate a scale factor, not a width every frame.
- **Ring gauge:** `Canvas.drawArc` from 0 to the progress; the leading cap dot orbits on the stroke's center line (radius = side / 2), not the inner edge; stagger rings by about 0.08 s; for progress above 100 percent draw a second arc and a shadowed cap dot to read as "beat the goal". Fitness-style ring gradients are the one place tuned vivid hues beat system colors.
- **Path loader:** sample the outline once (`Path.computeMetrics()` gives arc-length-even points through `getTangentForOffset`, which is why this is easy in Flutter), then animate only a progress head along the cached samples; draw a trail with fading radius and opacity; drive it from a ticker clock, never a spring. Equal arc length means constant speed; equal parameter steps speed up and slow down at corners. Prefer generic geometric shapes (star, polygon, infinity) over tracing brand logos.
- **Goo / metaball:** fuses and splits like liquid. The edge is hard after the threshold, so blobs are crisp at rest and gooey only when overlapping; keep blobs about the same size (a shrinking blob collapses its neck into a line); rest spacing must exceed diameter plus two blur radii or neighbors stay fused; slow the morph (response about 1.0); the canvas is visual only, real buttons sit on top; icons travel with their blob on the same animation. In Flutter this needs a fragment shader or a painter with a blur plus threshold color filter; it is an advanced pattern, ask before reaching for it.
- **Liquid step slider:** fill and thumb as one painted shape; keep blur at or under half the fill height; render the value bubble in the same coordinate space as the thumb (not through a later-measured callback, which misplaces it on first frame).
- **Accent from artwork:** downscale to about 40 px, weight each pixel by `saturation * 0.7 + brightness * 0.3` (not frequency, which returns the background), skip near-white and near-black outliers, darken a near-white winner (about 0.75), choose text by perceptual luminance (`0.299 r + 0.587 g + 0.114 b > 0.55` means dark text), not a channel average.

## Verification traps

- **Never verify a transition by pre-setting state to its destination.** A screen that starts already in the end state shows a finished picture and proves nothing about the motion. Trigger the change and capture a mid-transition frame.
- A shader or painter that compiles can still render nothing: look at it.
- Entrance animations screenshotted mid-opacity look washed out; wait, then capture. Backgrounded or throttled frames can hold an animation at its first frame: confirm the environment before "fixing" it.
- Reuse the same animation for the manual and the automatic path; two implementations drift.

## Not translated (no Flutter equivalent or needs a native target)

SF Symbol effects (bounce, wiggle, variableColor, drawOn): use cross-fade plus scale, or Lottie/Rive if the project already uses them. Native-physics scroll driven by an invisible `UIScrollView` (in Flutter, drive a `ScrollController` with real `BouncingScrollPhysics`). SceneKit objects and metallic badges (Flutter 3D needs a package or a shader). `GlassEffectContainer` morphing (see unslop-design `platforms/ios-glass.md`). Live Activities and the real Dynamic Island (a Widget Extension in native code; Flutter UI cannot render there). Metal shaders (Flutter fragment shaders exist but are an advanced, ask-first choice). Grid-to-cylinder morph and similar trig showpieces (principles: stagger radially from a pinch point and mirror it on return, quintic smoothstep in both directions, refuse taps mid-morph, spin-up by integrating the rate).
