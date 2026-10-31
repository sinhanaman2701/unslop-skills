# SwiftUI (native iOS)

SwiftUI is the platform's own toolkit, so most of `platforms/ios.md` is the default behaviour; slop here is fighting it. Keep it short: use the system component first.

| Need | Use |
| --- | --- |
| Screen structure | `NavigationStack` with `.navigationTitle` and `.navigationBarTitleDisplayMode(.large)`; `TabView` with SF Symbols |
| Settings or form lists | `List` / `Form` with `.listStyle(.insetGrouped)`; `LabeledContent` for label and value rows |
| Colors | semantic: `Color(.label)`, `.secondary`, `Color(.systemGroupedBackground)`, `.tint(...)` once at the app root |
| Type | `.font(.body)`, `.headline`, `.footnote`; `.monospacedDigit()` for figures; never fixed point sizes |
| Dynamic Type | `@Environment(\.dynamicTypeSize)`; `ViewThatFits` or `AnyLayout` to reflow a row into a column |
| Corners | `RoundedRectangle(cornerRadius:, style: .continuous)` (continuous is the default shape style for system components) |
| Icons | SF Symbols, one weight and rendering mode |
| Empty or error | `ContentUnavailableView` |
| Glass (iOS 26) | system components get it automatically; custom floating controls use `.glassEffect()` inside a `GlassEffectContainer`; never on content |
| Haptics | `.sensoryFeedback(.selection, trigger:)` |
| Reduce Motion | `@Environment(\.accessibilityReduceMotion)` |
| Adaptive width | `NavigationSplitView`; size classes through `@Environment(\.horizontalSizeClass)`, window size through `GeometryReader` or `containerRelativeFrame` |

Slop tells specific to SwiftUI: `.frame(width: 390)`, hard-coded safe-area padding, `Color.white` or `Color.black` literals, `.shadow(color: .purple, radius: 30)`, `LinearGradient` hero cards, `.font(.system(size: 13))` everywhere, `Text("Welcome back! 👋")`, a custom navigation bar built from `HStack`. Motion presets as SwiftUI code: `unslop-motion/references/stacks/swiftui.md`.
