# Verification

Build it, open it, look at it. Whatever does not run goes in the report as a deduction with the reason. Commands live in the stack file: `stacks/flutter.md`, `stacks/react-native.md`, `stacks/web.md` (SwiftUI: use the Xcode commands in the Flutter and React Native files, the simulator part is identical). If a flag is rejected, set the state by hand in the simulator's Settings app or the browser's DevTools.

## Screens and sizes

Mobile: open every audited screen on the smallest and the largest iPhone you ship to (an iPhone SE class device and a Pro Max class device), and an iPad if the app ships there. Web: five widths (320, 390, 768, 1024, 1440 px), plus 200 percent zoom. Watch the console for layout overflow errors and warnings.

## Matrix (mark each done, not run, or not applicable)

| Check | How (mobile / web) | Failure looks like |
| --- | --- | --- |
| Types and lints | the stack's analyzer and tests | analyzer errors |
| Overflow at small and large size | both device sizes / 320 px and 1440 px | clipped content, overflow errors, horizontal scroll |
| Cut text and stacked overlays | badges, pills, toasts at the smallest width and largest text | a word eaten by a clipping parent; two overlays in one corner |
| Largest text size | simulator largest accessibility size / browser text size 200 percent | clipped labels, overlapping rows, fixed-height boxes |
| Dark mode | simulator appearance / `prefers-color-scheme` emulation | invisible text, white cards, hard-coded colors |
| Increased contrast | simulator setting / `prefers-contrast: more` and forced colors | glass unreadable, hairlines vanish, focus ring gone |
| Real data | the best record and the worst; very long names; large numbers | layout hides on short data only |
| Empty, loading, error | force each; backend down; airplane mode | silent zero, eternal skeleton, error shown as empty |
| Layout shift | throttle images or data | cards jump when content arrives |
| Spacing that lies | screenshot, then check against the 4pt scale | more space inside a group than between groups; one sibling drifting |
| Keyboard | open a form (mobile: check inset and dismiss; web: tab through the whole flow) | field hidden by the keyboard; unreachable control; no visible focus |
| Tap targets | try every small control with a thumb | under 44 pt (web: under 24 px, or under 44 on touch screens) |
| Screen reader | VoiceOver on mobile; VoiceOver or NVDA on web | unlabeled controls, wrong reading order |
| Reduce Motion | on, then use the screen | movement remains; or the result is lost |
| Motion feel | slow the animation 4x and capture a mid-transition frame | bounce, more than one focus, blocking taps |
| Frame times | profile or release build on a physical device / DevTools Performance, CPU throttled | jank on scroll, blur or glass |
| Glass (iOS) | scroll content under it, then check the fallback paths | invisible effect, pulsing on moving elements |

## Cut text and overlap by eye

A leftover piece of a word can look like a short word. Check badges, action pills and toasts at the smallest width with the largest text size. A rule of thumb: any overlay that cannot wrap, or has a fixed width, and lives inside a clipping parent will eventually cut a word once the font or the language changes.

## Paid or destructive routes

Do not open a route that spends credits, charges a card or deletes data on load without a test account or a stub. Say which was used.

## Added discipline (from Visant's environment and verification notes, Impeccable's native audit and iOS rules)

**Say which evidence came from where.** Simulators and browsers give breadth (sizes, appearances, text sizes); posture, gestures, haptics, thermals and frame times need a physical device. Name which produced each finding and what stayed untested.

**No measurement counts before the screen is ready.**
1. The app is built and running in the mode you think it is (debug for iteration, profile or release for frame times; never judge speed in debug or the simulator).
2. The screen has settled: first frame drawn, data loaded, entrance animations finished (a screenshot taken mid-fade shows washed-out content and is not a rendering bug), and not still hot-reloading.
3. The device size and text scale are confirmed from the app (log them), not from the tool that claims it resized something.
4. The data is real and includes the worst record: very long names, big numbers, an address with no spaces, the empty and the error case, and once with the backend stopped. An empty screen hides every overflow, and a failed fetch painted as zero looks like success.
5. The measuring tool did not give up early (a half-built tree returns zero findings and zero content: treat that as a measurement failure, never as a clean screen).

**Re-measure after every fix.** A responsive fix trades one overflow for another (swapping a calendar grid for a list fixed the clipped titles and added 215 pt of overflow). Name the outermost overflowing element, not its leaves; list internal scrollers separately so intended scrolling is not confused with leakage.

**Native conformance probes** (each a yes or no on the running app). iOS: edge-swipe back works on every pushed screen; sheets dismiss by swipe and by a visible control; the tab bar stays on push; tap targets reach 44 pt; text is never clipped at the largest accessibility size; dark mode and increased contrast both look designed; VoiceOver reads each screen in a sensible order with meaningful labels; Reduce Motion removes movement and keeps results; the keyboard never hides the focused field; a permission is requested in context after an explanation, not at launch; the launch screen matches the first screen. Web: the whole flow works by keyboard alone with a visible focus ring; browser back never traps; zoom to 200 percent reflows with no horizontal scroll; dark scheme and reduced motion honored; every control has an accessible name; one `h1`; no layout shift on load; images carry dimensions and alt text.

**Motion leak audit.** With Reduce Motion on, anything still animating for more than 100 ms is a leak (decorative loops, parallax, springs). With normal motion, watch for loops that never stop, more than one animation focus on a screen, and animations that block a tap.

**Vision deficiency.** Information carried by color must also be carried by text, shape or position; check with the Accessibility Inspector, the simulator's display filters, or DevTools' vision-deficiency emulation.

**Height budget (work surfaces).** Count points from the top of the screen to the first item of real content, list each block, and report before and after: "460 pt to 64 pt, about two more rows above the fold" is a result; "cut the chrome" is not. A change that makes content taller must name what financed it.

**Keyboard audit (iPad, external keyboards, web).** Tab through the screen: Enter activates the focused control, Escape leaves a text field or closes a dialog, the primary action is reachable from a text field with a modifier, shortcuts are announced on their controls, nothing destructive sits on a bare reflex key.

**Honest reporting.** State what was verified and what was not, with the evidence type. Report the trade-off, not only the win. Say when a test failed and show the output. Say when a decision was left open and name it. Do not describe a screen you have not opened. When a user answers a `ship` with their own screenshot, that evidence outranks every capture you made: re-review from it.

## Learned from real runs (all stacks)

- **Use a dedicated simulator.** Create one for the project (`xcrun simctl create`) and install only there. A booted simulator may belong to the user's other work; installing, toggling appearance or content size on it changes their environment. If you must touch a shared one, say so afterwards.
- **Demo states are compile-time or URL-driven.** Pass the selected item, the clock or a baseline screen as a build-time define (Flutter `--dart-define`; React Native a launch constant or Expo extra) or a query string (web), not a runtime environment variable on the simulator, which was unreliable.
- **Capture before and after on the same device or browser, same data.** Compare light, dark, largest text, the empty or failed state, and a regular-width window.
- **Tests worth writing for every screen** (cheap, all caught something): Reduce Motion leaves nothing running; motion-on does animate and settles with nothing left looping; the largest text size raises no overflow; the main visual has one screen-reader label; the empty or "not today" state says its reason once. Give tests a phone-sized view so they need not scroll: scrolling leaves its own ticker running and gives a false "still animating".
