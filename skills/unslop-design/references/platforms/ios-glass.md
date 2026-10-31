# Glass pass (Liquid Glass era of iOS)

The rules apply to every stack. The implementation routes below are Flutter's; React Native: `BlurView` from `expo-blur` is a real system material and a native glass view may exist in the project's Expo version (`stacks/react-native.md`); SwiftUI: `.glassEffect()` (`stacks/swiftui.md`). Web: do not hand-roll glass; see `platforms/web.md`.

Run this pass only when the app targets an iOS version that has Liquid Glass and the Direction wants it. If the app does not, skip it; do not add glass to justify the pass.

## Rules (from Apple's usage and from what breaks)

1. **Glass is the floating control layer.** Navigation bars, tab bars, toolbars, floating buttons, sheets and menus. Never content: no glass cards, rows, or full-screen backgrounds.
2. **Never glass on glass.** Group neighbouring glass shapes into one layer so they blend; do not stack a second glass over the first.
3. **Busy content behind it.** Glass over a flat solid is nearly invisible and costs rendering for nothing. If nothing scrolls or shows beneath it, use a solid surface.
4. **Not on fast-moving elements.** A glass chip riding something being dragged re-samples its backdrop every frame and visibly pulses. Swap to a static translucent fill while it moves.
5. **Legibility first.** Check text contrast against the lightest and darkest content that can scroll behind. Add a quiet tint, not a heavier blur.
6. **Always have a fallback.** Older iOS, Android, low-power devices, and `MediaQuery.highContrastOf(context)` get an opaque or lightly translucent surface. Flutter does not expose iOS "Reduce Transparency" directly (verify in the Flutter version in use), so treat high contrast as the nearest signal.
7. **Static `Cupertino*` widgets do not become glass by themselves.** Flutter draws them itself; the system look does not apply automatically.
8. **System materials beat hand-rolled glass.** Apple's own guidance and Impeccable's iOS rules say to use system materials for blur and translucency behind bars and sheets and not to hand-roll glassmorphism. In Flutter the only way to get the real material is a native-hosted control (route B). Route A below is a degraded stand-in for a floating bar or chip, not a style to spread over cards, rows or backgrounds. Glass as decoration is on the refuse list.

## Choosing an implementation

Package status changes fast. Before using any package below, open its pub.dev page and read the version, the requirements and the warnings, then tell the user which route you picked and why.

| Route | What it is | Status when this skill was written (2026-10-31) | Use when |
| --- | --- | --- | --- |
| A. Frosted fallback (`BackdropFilter`) | Flutter-only blur plus tint plus hairline | Stable, ships anywhere | Default. Simple bars and chips |
| B. Native controls through platform views (for example `cupertino_native`) | Real UIKit controls hosted in Flutter, so the system draws the glass | `cupertino_native` 0.1.1 calls itself a proof of concept and lists a small widget set; needs a recent Xcode | System chrome (tab bar, switches, segmented controls) where authentic glass matters and the limits are acceptable |
| C. Shader glass (for example `liquid_glass_renderer`) | Flutter re-creates refraction, frost and glint with shaders | `1.0.0-dev` series, experimental, needs Impeller and the Flutter GPU preview, limited shapes per layer; its own docs say profile on devices | Custom shapes the system does not provide, and the user accepts an experimental dependency |
| D. Solid surface | Opaque semantic color plus hairline | Always | Anything that fails rules 3 to 6 |

Default to A. Move to B or C only when the user asks for authentic glass or the Direction depends on it, and say so in the report. Never add an experimental dependency silently.

## Route A: frosted fallback

```dart
import 'dart:ui' show ImageFilter;

class FrostedBar extends StatelessWidget {
  const FrostedBar({super.key, required this.child, this.radius = 24});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final solid = MediaQuery.highContrastOf(context);
    final fill = CupertinoColors.systemBackground
        .resolveFrom(context)
        .withValues(alpha: solid ? 1.0 : 0.72);
    final edge = CupertinoColors.separator.resolveFrom(context);
    final hairline = 1 / MediaQuery.devicePixelRatioOf(context);

    final surface = DecoratedBox(
      decoration: ShapeDecoration(
        color: fill,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: edge, width: hairline),
        ),
      ),
      child: child,
    );
    if (solid) return surface;

    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: surface,
      ),
    );
  }
}
```

If `ClipRSuperellipse` is not in the project's Flutter version, use `ClipRRect` with the same radius. `withValues(alpha:)` replaced `withOpacity` in recent Flutter; use whichever the project's version supports. Wrap the animated parent in `RepaintBoundary`, and keep the blurred area small: a full-screen backdrop blur is the main cost.

## Direction for glass

- One glass group per screen is usually enough. The signature detail should not be glass.
- Tint glass with the accent only to mark state (selected, destructive); never to decorate.
- Pair glass with quiet content behind it. A screen with colorful glass over colorful content has no hierarchy.
