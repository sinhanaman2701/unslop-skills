# React Native: motion tokens and recipes (Reanimated)

The numbers are in `../tokens.md`. React Native's `Animated` runs on the JS thread unless `useNativeDriver`; use **react-native-reanimated** (worklets on the UI thread) for anything gesture-driven, and `react-native-gesture-handler` for gestures. Check the project's installed versions first (`package.json`); the API below is Reanimated 3 and later. Status: the tokens, `Press`, `Enter` and the chart reveal and band retarget (`examples/tidewatch-rn`) type-check under `tsc --strict` against react-native 0.88; they were not run on a simulator or device in the session that wrote them, so the feel (springs, haptics, the reveal) is unverified. Extend an existing motion file before adding this one.

## Tokens

```ts
// motion.ts
import { Easing } from 'react-native-reanimated';

/** SwiftUI-style spring: response in seconds, damping ratio 0..1 -> Reanimated physics config. */
export const spring = (response: number, ratio: number) => {
  const stiffness = (2 * Math.PI / response) ** 2;
  return { mass: 1, stiffness, damping: 2 * ratio * Math.sqrt(stiffness) };
};

export const Springs = {
  snap: spring(0.35, 0.5), pop: spring(0.35, 0.6), settle: spring(0.4, 0.65), physics: spring(0.45, 0.7),
  morph: spring(0.6, 0.8), dial: spring(0.3, 0.7), press: spring(0.3, 0.6), enter: spring(0.5, 0.82),
  move: spring(0.4, 1), sheet: spring(0.3, 0.8),
  stiff: { mass: 1, stiffness: 220, damping: 22 },
} as const;

export const Motion = {
  curve: Easing.bezier(0.23, 1, 0.32, 1),
  move: Easing.bezier(0.77, 0, 0.175, 1),
  drawer: Easing.bezier(0.32, 0.72, 0, 1),
  press: 120, fast: 160, base: 200, slow: 300, enter: 360, exit: 250, reveal: 700,
  stagger: 50, maxStaggered: 6,
  riseDistance: 8, pressScale: 0.97, enterScale: 0.95,
} as const;

export const Wait = { instant: 100, loaderDelay: 300, loaderMinVisible: 500, narrate: 5000, escapeHatch: 10000 } as const;
```

## Reduce Motion

```ts
import { useReducedMotion } from 'react-native-reanimated';   // reads the system setting
```

Under Reduce Motion: no travel, scale or parallax; keep opacity and the result. Reanimated layout animations accept `.reduceMotion(ReduceMotion.System)` and follow the system by default in recent versions; check the installed one.

## Pressable (spring scale, cancel on drag-away)

```tsx
import React from 'react';
import { Pressable, type PressableProps, type StyleProp, type ViewStyle } from 'react-native';
import Animated, { useAnimatedStyle, useReducedMotion, useSharedValue, withSpring } from 'react-native-reanimated';
import { Motion, Springs } from './motion';

export function Press({ children, style, ...rest }: PressableProps & { children: React.ReactNode; style?: StyleProp<ViewStyle> }) {
  const reduce = useReducedMotion();
  const scale = useSharedValue(1);
  const opacity = useSharedValue(1);
  const anim = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }], opacity: opacity.value }));
  return (
    <Pressable
      {...rest}
      onPressIn={() => {
        if (reduce) opacity.value = 0.7;
        else scale.value = withSpring(Motion.pressScale, Springs.press);
      }}
      onPressOut={() => {
        opacity.value = 1;
        scale.value = withSpring(1, Springs.press);
      }}
    >
      <Animated.View style={[anim, style]}>{children}</Animated.View>
    </Pressable>
  );
}
```

`Pressable` already cancels when the finger drags away (`onPressOut` fires). Never add `android_ripple` on iOS.

## Entrance (one per screen, fade and rise, small stagger)

```tsx
import Animated, { FadeInDown } from 'react-native-reanimated';
import { Motion } from './motion';

export const Enter = ({ index = 0, children }: { index?: number; children: React.ReactNode }) => (
  <Animated.View
    entering={FadeInDown.duration(Motion.enter).delay(Math.min(index, Motion.maxStaggered - 1) * Motion.stagger).easing(Motion.curve)}
  >
    {children}
  </Animated.View>
);
```

`FadeInDown` rises from a fixed distance; if the default is larger than 6 to 12 px, build the entrance from `useAnimatedStyle` with `withTiming(…, { duration: Motion.enter, easing: Motion.curve })` and `Motion.riseDistance`. It plays once on mount, not on every re-render.

## Haptics

```ts
import * as Haptics from 'expo-haptics';           // bare RN: react-native-haptic-feedback
export const haptic = {
  select: () => Haptics.selectionAsync(),
  light: () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light),
  medium: () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium),
  success: () => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success),
  error: () => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error),
};
```

Gate on crossing a threshold and rearm on retreat (never fire per frame): inside a gesture worklet, use `runOnJS(haptic.medium)()` once when the value crosses the line, and reset a `crossed` shared value when it falls back under it.

## Drag with rubber band and release spring

```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
// rubber band: resistance grows with distance past the limit
const rubberBand = (d: number, limit: number) => (d <= limit ? d : limit + (d - limit) * 0.25);

const pan = Gesture.Pan()
  .onUpdate((e) => { y.value = rubberBand(e.translationY, 0); })
  .onEnd((e) => { y.value = withSpring(0, { ...Springs.physics, velocity: e.velocityY }); });
```

Springs retarget from the current value and velocity; never block input during an animation.

## Waiting

Use the anti-flicker pair (`Wait.loaderDelay`, `Wait.loaderMinVisible`) in a small hook: start a 300 ms timer when loading begins; show the skeleton only if still loading; once shown keep it 500 ms. Skeleton rows share the final row height. Shimmer: `withRepeat(withTiming(1, { duration: 1400, easing: Easing.linear }), -1)` on a transform of an overlay, static tint under Reduce Motion.

## Passages

Use the native stack for push and pop (swipe-back stays), `presentation: 'modal'` or `'formSheet'` for sheets. Tab switches cross-fade (no slide). Shared-element transitions: Reanimated's shared transitions where the installed version supports them, otherwise a fade; do not hang comprehension on the morph.

## Cheap properties and lifecycle

Animate `transform` and `opacity` in worklets (UI thread); never `setState` per frame; keep heavy work out of worklets; cancel animations on unmount with `cancelAnimation`. Profile in a release build on a device; the dev build and the simulator misreport frame times.

## Check

Slow-motion: temporarily scale the duration tokens (and spring responses) by 4 in `motion.ts` and capture a mid-transition frame in the simulator. Reduce Motion: toggle in the simulator (Settings, Accessibility, Motion) and confirm no travel.
