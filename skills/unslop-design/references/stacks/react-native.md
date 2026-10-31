# React Native (iOS first; Expo or bare)

Code for the iOS platform layer (`platforms/ios.md`) in React Native. React Native renders real UIKit views, so unlike Flutter several system looks come for free (`Switch`, `native-stack` headers, `BlurView`). The cost is the opposite trap: a web-minded layout (flex everything, custom headers, `TouchableOpacity` everywhere) that ignores them. Package names and APIs change quickly; before relying on any package below read its page and the project's `package.json` versions. Status of this file: the token, type, Pressable, entrance and chart code was written into a working example (`examples/tidewatch-rn`) and type-checked with `tsc` (strict) against react-native 0.88 and react-native-reanimated, and scanned with `slop-grep.sh --stack rn`. It was not run on a simulator or device in the session that wrote it (installing Expo Go was not permitted), so layout, gestures and haptics are unverified: run it before trusting it.

## Slop to native map

| Slop | Use |
| --- | --- |
| Custom `View` header with a back arrow | `@react-navigation/native-stack` (or Expo Router stack): `headerLargeTitle: true`, `headerTransparent`, `headerBlurEffect`, native swipe-back |
| Hand-drawn tab bar, hamburger drawer | bottom tabs (`@react-navigation/bottom-tabs`, or Expo Router native tabs if the SDK offers them) with SF Symbols; no drawer |
| `TouchableOpacity` everywhere, Android ripple | `Pressable` with a pressed style (opacity or scale; see `unslop-motion`); never `android_ripple` on iOS |
| A floating action button | primary action in the header (`headerRight`) or one in-content primary button |
| Custom switch, slider, segmented, picker | `Switch`, `@react-native-community/slider`, `@react-native-segmented-control/segmented-control`, `@react-native-community/datetimepicker` |
| `Modal` as a full-screen dialog | native-stack `presentation: 'modal'` or `'formSheet'` with a visible dismiss; `Alert.alert` and `ActionSheetIOS` for system alerts |
| Hairline made with `borderWidth: 1` | `StyleSheet.hairlineWidth` |
| Rounded corners that look like a CSS box | `borderCurve: 'continuous'` with `borderRadius` |
| Emoji icons or a web icon font | SF Symbols through `expo-symbols`, or one consistent icon library; never mixed |
| `ScrollView` with fake cards for settings | grouped list: `SectionList` styled as inset grouped |

## Theme: semantic colors that follow the system

```ts
import { DynamicColorIOS, PlatformColor, useColorScheme } from 'react-native';

export const Colors = {
  label: PlatformColor('label'),
  secondaryLabel: PlatformColor('secondaryLabel'),
  tertiaryLabel: PlatformColor('tertiaryLabel'),
  separator: PlatformColor('separator'),
  page: PlatformColor('systemGroupedBackground'),
  card: PlatformColor('secondarySystemGroupedBackground'),
  // The one accent, resolved per appearance by the system (replace with the Direction's values)
  accent: DynamicColorIOS({ light: '#C2410C', dark: '#FF8A4C' }),
} as const;
```

`PlatformColor` and `DynamicColorIOS` resolve natively, so dark mode, increased contrast and elevated surfaces work. Do not run them through `Color(...)` manipulation libraries (they return opaque objects). For tints at an alpha, build a separate `DynamicColorIOS` token. `useColorScheme()` is for the rare JS-side decision, not for colors.

## Type and spacing tokens

```ts
import { StyleSheet } from 'react-native';

export const Space = { s4: 4, s8: 8, s12: 12, s16: 16, s20: 20, s24: 24, s32: 32, s40: 40, s48: 48, s64: 64 } as const;

// The default iOS font is the system font (SF); leave fontFamily unset.
export const Type = StyleSheet.create({
  footnote: { fontSize: 13, color: Colors.secondaryLabel },
  callout: { fontSize: 16, color: Colors.secondaryLabel },
  body: { fontSize: 17, color: Colors.label },
  headline: { fontSize: 17, fontWeight: '600', color: Colors.label },
  figure: { fontSize: 17, fontVariant: ['tabular-nums'], color: Colors.label },
  answer: { fontSize: 34, fontWeight: '600', fontVariant: ['tabular-nums'], color: Colors.label },
});
```

`Text` scales with the system text size by default; never set `allowFontScaling={false}` on content. For a display figure that can balloon, set `maxFontSizeMultiplier={1.8}` on that `Text` only. Test the largest accessibility size in the simulator (Settings, Accessibility, Display and Text Size, Larger Text).

## Safe areas, tap targets, adaptive

- `react-native-safe-area-context` (`SafeAreaView`, `useSafeAreaInsets`); never hard-code a status bar offset. Native-stack headers handle their own inset.
- Targets 44 x 44: `hitSlop` extends a small icon's hit area without changing its look.
- Regular width: `useWindowDimensions().width >= 700` restructures to master-detail (list on the left, detail on the right); this follows the window, so Split View and Stage Manager work. A stretched phone column on iPad is the failure.
- `KeyboardAvoidingView` (iOS: `behavior="padding"`) or a keyboard-aware scroll view; keyboard and input insets in every configuration.

## Lists with states

Use `FlatList` / `SectionList`; give rows a stable `keyExtractor`; render three states from one sealed type (`loading` skeleton in the final row height, `empty` that says what will appear, `error` with retry). `contentInsetAdjustmentBehavior="automatic"` lets a large title collapse with the scroll. Avoid `ScrollView` plus `.map` for long lists.

## Materials and glass

`expo-blur` `BlurView` uses the system `UIVisualEffectView`, so `tint="systemMaterial"` is a real system material, unlike Flutter's blur. Use it only for floating controls over scrolling content, with a solid fallback when Reduce Transparency is on (`AccessibilityInfo.isReduceTransparencyEnabled()`). Liquid Glass: check whether the project's Expo or React Native version ships a native glass view (`expo-glass-effect` at the time of writing); the rules in `platforms/ios-glass.md` apply unchanged (floating controls only, never glass on glass, never content).

## Accessibility baseline

`accessibilityRole`, `accessibilityLabel` and `accessibilityState` on every custom tappable; `accessible={false}` on decoration; respect `AccessibilityInfo.isReduceMotionEnabled()` (Reanimated: `useReducedMotion()`), bold text and increased contrast; every custom gesture has a tap alternative. Test with VoiceOver once per screen.

## Performance

`React.memo` rows and stable callbacks for large lists; Reanimated worklets for gesture-driven motion (never `setState` per frame); `expo-image` or `FastImage` for cached images with `contentFit` and a placeholder; avoid big `shadow*` blurs on scrolling rows. Profile a release build on a physical device; the dev build and the simulator lie about frame times.

## Verify

Run on an iOS simulator (`npx expo run:ios` or `npx expo start --ios` with a compatible Expo Go) and screenshot with `xcrun simctl io <dedicated-sim> screenshot`; create a dedicated simulator rather than reusing a booted one (`unslop-review/references/verification.md`). Types: `npx tsc --noEmit`; lint: `npx eslint`.
