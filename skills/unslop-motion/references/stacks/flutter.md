# Flutter: motion tokens as Dart

Copy this into the project as `motion.dart` (once). First search the project for an existing motion token file and extend it instead; two token files means drift. The numbers are defined in `tokens.md`; this file is only their Dart form. Compiled and run on Flutter 3.47 with iOS 27 simulators.

```dart
import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// SwiftUI-style spring: response in seconds, damping ratio 0..1.
SpringDescription spring(double response, double dampingFraction) {
  final omega = 2 * math.pi / response;
  return SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: omega * omega,
    ratio: dampingFraction,
  );
}

abstract final class Springs {
  static final snap = spring(0.35, 0.50);    // playful, visible bounce (rare)
  static final pop = spring(0.35, 0.60);     // toggles, chips
  static final settle = spring(0.40, 0.65);  // small cards
  static final physics = spring(0.45, 0.70); // dragged card released
  static final morph = spring(0.60, 0.80);   // reshape, glass morph
  static final dial = spring(0.30, 0.70);    // scrubbing, numbers
  static final press = spring(0.30, 0.60);   // press down and release
  static final enter = spring(0.50, 0.82);   // content assembling
  // Stiff, mechanical: SwiftUI interpolatingSpring(stiffness: 220, damping: 22)
  static const stiff = SpringDescription(mass: 1, stiffness: 220, damping: 22);

  // Apple "Designing Fluid Interfaces" defaults (damping ratio / response):
  static final move = spring(0.4, 1.0);      // reposition: critically damped, no bounce
  static final rotate = spring(0.4, 0.8);
  static final sheet = spring(0.3, 0.8);     // drawer or sheet
}

abstract final class Motion {
  // Three curves, no more.
  static const curve = Cubic(0.23, 1, 0.32, 1);    // enter / exit / responds to input: the default
  static const move = Cubic(0.77, 0, 0.175, 1);    // an element moving or morphing on screen
  static const drawer = Cubic(0.32, 0.72, 0, 1);   // sheets and drawers, iOS-like

  // Duration scale for anything the finger is waiting on (under 300 ms).
  static const press = Duration(milliseconds: 120);   // press feedback
  static const fast = Duration(milliseconds: 160);    // tooltips, small popovers
  static const base = Duration(milliseconds: 200);    // menus, selects, cards, list items
  static const slow = Duration(milliseconds: 300);    // sheets and larger surfaces

  // Content that is arriving (not waiting on a finger) may take longer.
  static const enter = Duration(milliseconds: 360);   // 300-500
  static const exit = Duration(milliseconds: 250);    // about 70% of enter
  static const reveal = Duration(milliseconds: 700);  // the one authored moment per screen (a chart drawing in)
  static const stagger = Duration(milliseconds: 50);  // 30-80, six items max
  static const maxStaggered = 6;

  static const riseDistance = 8.0;     // pt, 6-12
  static const pressScale = 0.97;      // icon buttons 0.92, wide rows 0.985
  static const enterScale = 0.95;      // never scale from 0
}

/// Perception thresholds for waiting, in milliseconds.
abstract final class Wait {
  static const instant = Duration(milliseconds: 100);        // below this show nothing
  static const loaderDelay = Duration(milliseconds: 300);    // never mount a loader sooner
  static const loaderMinVisible = Duration(milliseconds: 500); // once shown, hold this long
  static const narrate = Duration(seconds: 5);               // name the running step
  static const escapeHatch = Duration(seconds: 10);          // offer cancel / background
}
```

Reduce Motion: `MediaQuery.disableAnimationsOf(context)`. Haptics: `HapticFeedback.selectionClick()` and `light/medium/heavy`; success, warning and error notification haptics need a plugin (check pub.dev). Slow-motion check: set `timeDilation = 4.0` (`package:flutter/scheduler.dart`) in a debug build. Cheap properties: `Transform`, `FadeTransition`, `ScaleTransition`, `AnimatedBuilder.child`, `RepaintBoundary`. Lifecycle: every `AnimationController` has a `vsync`, is disposed, and is never started from `build`; timers are cancelled in `dispose`. Native widgets that already animate and haptic correctly: `CupertinoSwitch`, `CupertinoSlidingSegmentedControl`, `CupertinoContextMenu`, `showCupertinoModalPopup`, `CupertinoPageRoute`. Passages: `CupertinoPageRoute` (push), `Hero` (shared element), `AnimatedSwitcher` (same place, different content), `AnimatedList` / `AnimatedPositioned` (reshuffle in place).

Recipes: `flutter-recipes.md`. Patterns: `flutter-patterns.md`.
