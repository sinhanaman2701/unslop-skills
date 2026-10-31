# Recipes

Token file, `Pressable`, `Entrance` and `ThresholdHaptic` were compiled and run on Flutter 3.47 with iOS 27 simulators; the other recipes were written from the public APIs and not compiled. Run `flutter analyze` and adapt names to the project's Flutter version. All recipes assume the token file from `flutter.md`.

## Pressable (press feedback with spring, cancel on drag-away)

```dart
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'motion.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onPressed,
    required this.child,
    this.pressedScale = Motion.pressScale,
    this.hapticOnDown = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double pressedScale;
  final bool hapticOnDown; // opt in for meaningful actions only

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  // unbounded so the spring may overshoot past 1.0
  late final AnimationController _scale =
      AnimationController.unbounded(vsync: this, value: 1);

  void _animateTo(double target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _scale.value = target;
      return;
    }
    _scale.animateWith(
      SpringSimulation(Springs.press, _scale.value, target, _scale.velocity),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (_) {
              _animateTo(widget.pressedScale);
              if (widget.hapticOnDown) HapticFeedback.lightImpact();
            }
          : null,
      onTapUp: enabled ? (_) => _animateTo(1) : null,
      onTapCancel: enabled ? () => _animateTo(1) : null, // drag-away cancels
      onTap: widget.onPressed,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
```

`GestureDetector` already cancels the tap when the finger drifts out of slop range, which gives lift-inside-to-fire behavior. Inside a scroll view it does not block scrolling.

## Momentum projection (flick that feels thrown)

```dart
/// Where a flick will rest. 0.998 is the usual deceleration rate.
double projectedEnd(double position, double velocityPxPerSec, {double rate = 0.998}) =>
    position + (velocityPxPerSec / 1000) * rate / (1 - rate);

// On drag end: snap to the nearest target of the projected end, not of the finger.
int pageAfterFlick(double offset, double velocity, double pageWidth, int current, int count) {
  final end = projectedEnd(offset, velocity);
  final target = (end / pageWidth).round().clamp(0, count - 1);
  return target == current && (end - offset).abs() > 52
      ? (end > offset ? current + 1 : current - 1).clamp(0, count - 1)
      : target;
}
```

Animate from the live value with `SpringSimulation(Springs.physics, value, target, velocity)` so a second touch interrupts cleanly and blends velocity instead of snapping.

## Threshold haptic that rearms

```dart
import 'package:flutter/services.dart';

/// Fires once per crossing; retreating past the line rearms it.
class ThresholdHaptic {
  bool _crossed = false;

  void update(double value, double threshold) {
    if (!_crossed && value > threshold) {
      _crossed = true;
      HapticFeedback.mediumImpact();
    } else if (_crossed && value <= threshold) {
      _crossed = false;
    }
  }

  void reset() => _crossed = false; // call on drag end
}
```

A plain `fired` boolean that is never reset buzzes once per gesture, not once per crossing. Give touch-down feedback a small dead zone (a few pt) so jitter at gesture start does not fire it.

## Rubber-band resistance for a drag past its limit

```dart
/// Same curve family as UIScrollView overscroll. 0.55 is the usual constant.
double rubberBand(double offset, double limit, {double k = 0.55}) {
  final x = offset.abs();
  return offset.sign * (1 - 1 / (x * k / limit + 1)) * limit;
}
```

Use it in `onPanUpdate` while dragging; on release animate back with `Springs.physics` starting from the current offset and velocity.

## Entrance (one per screen, fade and rise, small stagger)

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'motion.dart';

class Entrance extends StatefulWidget {
  const Entrance({super.key, this.index = 0, required this.child});
  final int index;
  final Widget child;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Motion.enter);
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return; // once, not on every dependency change
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
      return;
    }
    final steps = widget.index.clamp(0, Motion.maxStaggered - 1);
    _timer = Timer(Motion.stagger * steps, _c.forward);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = Motion.curve.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * Motion.riseDistance),
            child: child,
          ),
        );
      },
    );
  }
}
```

Use only on the first screenful of a screen. Do not wrap rows of a long or frequently refreshed list.

## Count-up for a changing figure

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: total), // later rebuilds animate from the current value
  duration: const Duration(milliseconds: 400),
  curve: Motion.curve,
  builder: (context, value, _) => Text(
    format(value),
    style: const TextStyle(
      fontSize: 28,
      fontFeatures: [FontFeature.tabularFigures()], // import 'dart:ui'
    ),
  ),
)
```

Format the whole number with one function so currency symbols do not jitter during the roll; for a symbol that glitches, render it in a separate static `Text`. Pair a discrete selector change with `HapticFeedback.selectionClick()`.

## Error shake (error only, never decorative)

```dart
// controller: AnimationController(vsync: this, duration: Duration(milliseconds: 300))
final dx = math.sin(controller.value * math.pi * 6) * 6 * (1 - controller.value);
Transform.translate(offset: Offset(dx, 0), child: field);
```

Trigger once with `controller.forward(from: 0)` when validation fails; skip under Reduce Motion and show the error text only.

## Cross-fade for a state swap (icon, label)

```dart
AnimatedSwitcher(
  duration: Motion.fast,
  switchInCurve: Motion.curve,
  transitionBuilder: (child, anim) => FadeTransition(
    opacity: anim,
    child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(anim), child: child),
  ),
  child: KeyedSubtree(key: ValueKey(state), child: iconFor(state)),
)
```

Flutter has no equivalent of SF Symbol effects. A cross-fade with a small scale is the default; use Lottie or Rive only if the project already depends on them.

## Skeleton, not spinner

Paint the real structure (label, rule, title), and replace only the value with a rounded box roughly its width. The box is static, or fades between two neutral tones over 1.2 seconds only while genuinely loading. Never collapse the card to a spinner.

## Reviewing motion

```dart
import 'package:flutter/scheduler.dart';
// in a debug-only main or dev menu:
timeDilation = 4.0; // everything runs at quarter speed
```

Check: does anything move that does not need to? Does anything overshoot more than once? Can a second tap interrupt it cleanly? Does Reduce Motion remove the movement and keep the result?

## Loading: the anti-flicker pair (from waiting.md)

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'motion.dart';

/// Shows [loader] only when [active] stays true past [delay], then keeps it
/// for at least [minVisible]. Until then the current [child] holds.
class DelayedLoader extends StatefulWidget {
  const DelayedLoader({
    super.key,
    required this.active,
    required this.loader,
    required this.child,
    this.delay = Wait.loaderDelay,
    this.minVisible = Wait.loaderMinVisible,
  });

  final bool active;
  final Widget loader;
  final Widget child;
  final Duration delay;
  final Duration minVisible;

  @override
  State<DelayedLoader> createState() => _DelayedLoaderState();
}

class _DelayedLoaderState extends State<DelayedLoader> {
  bool _visible = false;
  DateTime? _shownAt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(DelayedLoader old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  void _sync() {
    _timer?.cancel();
    if (widget.active == _visible) return;
    if (widget.active) {
      _timer = Timer(widget.delay, () {
        if (!mounted) return;
        _shownAt = DateTime.now();
        setState(() => _visible = true);
      });
    } else {
      final shownFor = DateTime.now().difference(_shownAt ?? DateTime.now());
      final remaining = widget.minVisible - shownFor;
      _timer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
        if (!mounted) return;
        setState(() => _visible = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: Motion.base,
        child: _visible ? widget.loader : widget.child,
      );
}
```

Pass `loader` as a skeleton of the final layout. If the data arrives before `loaderDelay`, the loader never mounts.

## Counting numbers

A count-up is justified only when the number changed as a consequence of a user action and the change is the information. Never on first load, never on a ticking number, never more than one counter animating on a screen (two counters become a casino). Use `Motion.base` at most, tabular figures, and under Reduce Motion show the final value. A value the user is producing by hand (dragging a slider) does not animate at all: it follows the finger.
