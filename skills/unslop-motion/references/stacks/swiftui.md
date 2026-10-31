# SwiftUI: motion

The spring convention in `../tokens.md` is SwiftUI's own, so the presets map one to one. Prefer system components (they animate and give haptics correctly) and `withAnimation` over hand-driven timers.

```swift
extension Animation {
    static let snap    = Animation.spring(response: 0.35, dampingFraction: 0.50)  // playful, rare
    static let pop     = Animation.spring(response: 0.35, dampingFraction: 0.60)  // toggles, chips
    static let settle  = Animation.spring(response: 0.40, dampingFraction: 0.65)  // small cards
    static let physics = Animation.spring(response: 0.45, dampingFraction: 0.70)  // dragged card released
    static let morph   = Animation.spring(response: 0.60, dampingFraction: 0.80)  // reshape
    static let dial    = Animation.spring(response: 0.30, dampingFraction: 0.70)  // scrubbing, numbers
    static let press   = Animation.spring(response: 0.30, dampingFraction: 0.60)
    static let enter   = Animation.spring(response: 0.50, dampingFraction: 0.82)
    static let stiff   = Animation.interpolatingSpring(stiffness: 220, damping: 22)
    static let curve   = Animation.timingCurve(0.23, 1, 0.32, 1, duration: 0.2)   // base duration, default easing
}
```

- **Press:** a `ButtonStyle` with `.scaleEffect(configuration.isPressed ? 0.97 : 1)` and `.animation(.press, value: configuration.isPressed)`.
- **Haptics:** `.sensoryFeedback(.selection, trigger: value)`, `.impact(weight: .light)`, `.success`. Fire on a discrete change, never per frame.
- **Reduce Motion:** `@Environment(\.accessibilityReduceMotion) var reduce`; when true use `.opacity` transitions and no offsets or scales.
- **Entrance:** `.transition(.opacity.combined(with: .offset(y: 8)))` with `.animation(.enter, value:)`; stagger with `.delay(Double(i) * 0.05)`, six items at most.
- **Passages:** `NavigationStack` push and swipe-back are the system's; `matchedGeometryEffect` or `.navigationTransition(.zoom(sourceID:in:))` for a shared-element morph; sheets are `.sheet`.
- **Slow-motion check:** `.animation(.default.speed(0.25))` temporarily, or the Simulator's Debug, Slow Animations.
