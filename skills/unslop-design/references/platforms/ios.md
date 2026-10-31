# iOS conformance (HIG)

Rules from Apple's Human Interface Guidelines as distilled by platform-design-skills (ehmo, MIT) and Impeccable's iOS reference. Widget and API names are Flutter's; for React Native and SwiftUI use the equivalents in `stacks/react-native.md` and `stacks/swiftui.md`. Flutter draws its own pixels, so there conformance is something you build, not something you get; React Native and SwiftUI get much of it from the system. Check each rule on the running app.

## Structure and navigation (critical)

- **Tab bar for 3 to 5 top-level sections** (sections, never actions), at the bottom, filled icon when selected and outline otherwise, never hidden on push, badges only for counts that matter. More than five: consolidate or use a More tab. Flutter: `CupertinoTabScaffold` + `CupertinoTabBar`; one navigator per tab so each tab keeps its stack and scroll.
- **No hamburger or drawer.** It hides navigation. No Material `Drawer`.
- **Large titles** on top-level screens, inline on deeper ones: `CupertinoSliverNavigationBar`.
- **Never override the back swipe** or the other system edge gestures (left edge back, top corners, bottom home). `CupertinoPageRoute`; avoid `PopScope(canPop: false)` except for unsaved data with a confirm.
- **Preserve state** across back navigation and tab switches (scroll position, input, filters); recognition over recall: keep location, recent choices and destinations visible.
- **Thumb zone.** Primary action in the bottom half; secondary actions and navigation at the top.
- **Modality sparingly.** A sheet for a self-contained, dismissible sub-task with Cancel and Done (or a close) and swipe down; a full-screen cover for immersion; never stack modals; never a non-dismissable modal. A modal is rarely the first answer: try inline or progressive disclosure first.
- **Alerts for critical decisions only**, two buttons (three at most), destructive role for the destructive one. A tip is a banner or an inline message, not an alert. `CupertinoAlertDialog`, `CupertinoActionSheet`.
- **Lists:** inset grouped by default, minimum row height 44, swipe actions for common operations, grouped lists for settings-shaped content (no bespoke card stacks). Context menus (`CupertinoContextMenu`) for secondary actions, never the only path to one.
- **Search:** `CupertinoSearchTextField`; suggestions and recents.
- **Progress:** determinate when you know, indeterminate inline otherwise; never a full-screen blocking spinner (skeleton instead).
- **Controls:** `CupertinoSwitch`, `CupertinoSlidingSegmentedControl` (2 to 5 options), `CupertinoPicker`, system date pickers. Reinventing these for flavor is the most common native slop.
- **Buttons:** one prominent primary per screen; bordered for secondary; plain for tertiary; destructive in red text with a confirm or an undo. Shared roles in one component, not per screen.

## Layout

- Safe areas always (`SafeArea`, `MediaQuery.paddingOf`). Background fills may extend under; text and controls never.
- Tap targets 44 x 44 pt minimum (`kMinInteractiveDimensionCupertino`), with space between adjacent targets.
- Support iPhone SE (375 pt wide) through Pro Max (430 pt); no hard-coded widths; landscape unless the task is camera-like.
- 8 pt rhythm with 4 pt for fine adjustments.

## Typography and color

- iOS text styles, Dynamic Type through the accessibility sizes, layouts that reflow (switch a Row to a Column when `MediaQuery.textScalerOf(context)` is large; never clip essential text). A custom font must scale too: Flutter scales `Text` by the text scaler, so never pin it.
- 11 pt floor; body 17.
- System font (SF Pro) carries the UI; a brand face only in display moments.
- Semantic system colors; dark mode designed, not inverted; ONE tint for interactive elements; three-level background hierarchy (system, secondary, tertiary); never color alone for meaning; 4.5:1 text contrast; Display P3 for vivid brand colors; Increase Contrast variants for custom colors.

## Accessibility (critical)

- `Semantics` labels on every custom tappable (an icon-only button reads its file name otherwise); logical reading order (`SemanticsSortKey`); decorative images excluded.
- Respect Bold Text (`MediaQuery.boldTextOf`), Reduce Motion (`disableAnimationsOf`), Increase Contrast (`highContrastOf`), Invert Colors where relevant.
- Every custom gesture has a tap or menu alternative; never convey information only by color, shape or position.
- Works with Switch Control and full keyboard access (a Bluetooth keyboard on iPad): focus order, visible focus, `Shortcuts`/`Actions`.

## Patterns

- **Onboarding:** three pages at most, skippable, defer sign-in until a feature needs it; empty states are onboarding (what will appear, why it matters, how to start, one illustration).
- **Launch screen matches the first screen**; no splash logo.
- **Permissions in context**, never at launch: show a short explanation first (the system dialog appears only once; if denied, point to Settings), then request. Offer a one-time location button where it fits.
- **Sign in with Apple** must be offered, first, if the app offers any third-party sign-in. Do not require an account until a feature needs one. Respect App Tracking Transparency; do not degrade the experience on denial.
- **Settings:** frequent ones in-app; privacy and permission controls defer to the system Settings app; never duplicate system controls.
- **Notifications** only for content people care about; categorized and actionable.
- **Feedback:** immediate visual state change plus a haptic for significant actions; acknowledge the tap at once and show inline progress for anything slow.
- **Interruptions:** save state and pause on `AppLifecycleState` changes (calls, Siri, app switcher).
- **Icons:** one set; prefer `CupertinoIcons` or an SF-Symbols-faithful package; match weight to adjacent text; never mix a web icon set.
- System integration (widgets, App Shortcuts, Spotlight, Live Activities, Dynamic Island) needs native extensions; flag them to the user as a native task, do not fake them in Flutter.

## iPad and adaptive

Adaptation is rethinking the experience for the new context, not scaling.

- **Restructure, do not stretch.** A stretched phone column on iPad is the failure. Drive structure from window size (`MediaQuery.sizeOf`, `LayoutBuilder` with named breakpoints), never from the device model: Split View, Slide Over and Stage Manager hand you any width, including a phone width on an iPad.
- Tab bar becomes a sidebar in regular width; master-detail (list and detail side by side) and multi-column grids use the width; popovers anchor to their source (not full-screen sheets).
- Landscape restructures into side-by-side panes; never clip or letterbox; lock orientation only when the task truly demands it.
- Keyboard shortcuts for frequent actions (do not claim system ones: Cmd+H, Cmd+Tab, Cmd+Space); hover states for pointer users (`MouseRegion`); drag and drop for text, images and URLs; do not hard-code dimensions.
- Handle keyboard and input insets in every configuration (`MediaQuery.viewInsetsOf`).
- Test at least one phone and one tablet size and both orientations on simulators for breadth, then hardware for posture, gestures and performance.

## Web or Android port?

If the screen was ported from a website or Android (the web side of that: `platforms/web.md`): reconform, do not reflow. Replace web navigation with the platform's, HTML-shaped controls with Cupertino ones, hover affordances with touch-first ones, and px type with Dynamic Type; then judge it by the iOS slop test.
