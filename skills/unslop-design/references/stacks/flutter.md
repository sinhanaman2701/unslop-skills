# Flutter (iOS): widgets, theme and code

Snippets were compiled and run on Flutter 3.47 / iOS 27 simulators in a worked example (Tidewatch, `examples/tidewatch`). Still run `flutter analyze` after pasting, and check a class exists in the project's Flutter version.

## Material to Cupertino map

| Slop (Material on iOS) | Use |
| --- | --- |
| `MaterialApp`, `Scaffold`, `AppBar` | `CupertinoApp`, `CupertinoPageScaffold`, `CupertinoSliverNavigationBar` (large title) |
| `BottomNavigationBar` / `NavigationBar` | `CupertinoTabScaffold` + `CupertinoTabBar` |
| `Drawer`, hamburger | tab bar or a push |
| `FloatingActionButton` | primary action in the navigation bar trailing slot, or one in-content primary button |
| `ListTile` + dividers | `CupertinoListSection.insetGrouped` + `CupertinoListTile` |
| `Switch`, `Slider`, `Checkbox` | `CupertinoSwitch`, `CupertinoSlider`, a checkmark row |
| `TabBar` for 2 to 5 options | `CupertinoSlidingSegmentedControl` |
| `showModalBottomSheet`, `AlertDialog`, `PopupMenuButton` | `showCupertinoModalPopup`, `showCupertinoDialog` / `CupertinoAlertDialog`, `CupertinoContextMenu` or `CupertinoActionSheet` |
| `InkWell` / ripple | pressed-state opacity or scale (see unslop-motion `Pressable`) |
| `MaterialPageRoute` | `CupertinoPageRoute` (swipe-back) |
| `ScrollPhysics` clamping | `BouncingScrollPhysics` |
| `SnackBar` | inline state change or a quiet toast |

If the app also ships on Android, keep Material there and branch on `defaultTargetPlatform` at the shell level only. Do not scatter platform checks through every widget.

## Theme

```dart
CupertinoApp(
  theme: const CupertinoThemeData(
    // brightness left null so the app follows the system setting
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: CupertinoColors.systemBackground,
  ),
  home: const HomeScreen(),
)
```

## Tokens as code

```dart
abstract final class Space {
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20,
      s24 = 24, s32 = 32, s40 = 40, s48 = 48, s64 = 64;
}

abstract final class AppColors {
  // Brand accent that stays readable on both backgrounds.
  static const accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0A5FD8),      // replace with the Direction's accent, light
    darkColor: Color(0xFF5B9BFF),  // and dark
  );

  static Color label(BuildContext c) => CupertinoColors.label.resolveFrom(c);
  static Color secondary(BuildContext c) => CupertinoColors.secondaryLabel.resolveFrom(c);
  static Color tertiary(BuildContext c) => CupertinoColors.tertiaryLabel.resolveFrom(c);
  static Color separator(BuildContext c) => CupertinoColors.separator.resolveFrom(c);
  static Color card(BuildContext c) =>
      CupertinoColors.secondarySystemGroupedBackground.resolveFrom(c);
  static Color page(BuildContext c) =>
      CupertinoColors.systemGroupedBackground.resolveFrom(c);
}
```

Colors that do not resolve against the context do not adapt to dark mode. Resolve at build time, never cache a resolved color in a static.

## Type

```dart
extension AppText on BuildContext {
  TextStyle get _base => CupertinoTheme.of(this).textTheme.textStyle;

  TextStyle get headline =>
      _base.copyWith(fontSize: 17, fontWeight: FontWeight.w600);
  TextStyle get body => _base.copyWith(fontSize: 17);
  TextStyle get footnote => _base.copyWith(
      fontSize: 13, color: CupertinoColors.secondaryLabel.resolveFrom(this));
  TextStyle get figure => _base.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()]);
}
```

`Text` scales with the system text size automatically; do not pass `textScaler: TextScaler.noScaling` on content. Verify the largest accessibility size in the simulator (Settings, Accessibility, Display and Text Size, Larger Text).

## Continuous corners

```dart
DecoratedBox(
  decoration: ShapeDecoration(
    color: AppColors.card(context),
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(Space.s16),
    child: content,
  ),
)
```

`RoundedSuperellipseBorder` is the framework's iOS-style corner. If the Flutter version in use does not have it, a `smooth_corner`-style package or a plain `RoundedRectangleBorder` is the fallback; do not use `ContinuousRectangleBorder` (a poor match to the iOS curve). To clip children to the same shape: `ClipPath(clipper: ShapeBorderClipper(shape: shape), child: ...)`.

## Hairline

```dart
final hairline = 1 / MediaQuery.devicePixelRatioOf(context);
Container(height: hairline, color: AppColors.separator(context));
```

## Tap target

```dart
ConstrainedBox(
  constraints: const BoxConstraints(
    minWidth: kMinInteractiveDimensionCupertino,
    minHeight: kMinInteractiveDimensionCupertino,
  ),
  child: button,
)
```

## Grouped list with states

```dart
CupertinoListSection.insetGrouped(
  header: const Text('Recent'),
  children: [
    for (final r in rows)
      CupertinoListTile(
        title: Text(r.title),
        additionalInfo: Text(r.meta),
        trailing: const CupertinoListTileChevron(),
        onTap: () => open(r),
      ),
  ],
)
```

The section header is rendered by the system; leave its casing alone. Pair every list with a skeleton of the final row height, an empty state that says what is missing, and an error state with retry. Use sealed state classes so the three cannot be confused.

## Accessibility baseline

- `Semantics(label:, button: true)` on custom tappables; `excludeSemantics` on decorative images
- `MediaQuery.disableAnimationsOf(context)` and `MediaQuery.boldTextOf(context)` respected; `highContrast` falls back to solid surfaces
- Color is never the only carrier of meaning (add icon or text)
- Test with VoiceOver once per screen

## Performance

- `const` constructors on static subtrees; split large `build` methods
- `RepaintBoundary` around animated or blurred regions
- `cacheWidth` / `cacheHeight` on large images; `precacheImage` for hero images
- Avoid `Opacity` on big subtrees every frame (use `FadeTransition`); avoid `saveLayer` triggers such as stacked clipped blurs
- Profile on a physical device in profile mode, not the simulator

## Lessons from running a real screen

- **`cupertino_icons` must be in `pubspec.yaml`.** Without it every `CupertinoIcons.*` renders as a "?" box, including in `CupertinoTabBar`.
- **`CupertinoListSection.insetGrouped` spacing:** control the gap above with `topMargin` and the side/bottom inset with `margin`. There is no `headerMargin`. The header is a plain `Text` in `footnote` style; do not restyle it as an uppercase label.
- **Display figures clamp, body text does not.** A hero number can balloon at accessibility sizes. Wrap only that widget: `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.8, child: Text(...))`. Everything else scales fully.
- **Regular width restructures, it does not stretch.** Branch on `MediaQuery.sizeOf(context).width >= 700` (not device model; Split View and Stage Manager give any app any width): choices in a fixed ~360 pt column on the left, the answer and its evidence on the right. A phone layout centered in a wide window is a failure.
- **Reduce Motion: bypass, do not zero.** `AnimatedSwitcher(duration: Duration.zero)` still runs a controller for a frame. Under `MediaQuery.disableAnimationsOf(context)` render the child directly, and set controllers to their end value instead of calling `forward()`.
- **One signature, rationed.** A single drawn mark (here the orange "float" dot) appears only on "now" and the selected item. If it can be repeated on every row, it is decoration.
