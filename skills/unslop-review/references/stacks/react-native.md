# React Native verification

```bash
npx tsc --noEmit && npx eslint .
npx expo start --ios            # Expo; or: npx expo run:ios (builds a dev client), or: npx react-native run-ios
bash ~/.claude/skills/unslop-review/scripts/slop-grep.sh --stack rn src   # or app/, components/
```

Use a dedicated simulator (see `flutter.md` for the `xcrun simctl` commands: create, boot, install, `io screenshot`, `ui appearance`, `ui content_size`, `ui increase_contrast`; they are stack-independent). Reduce Motion, Reduce Transparency, Bold Text and VoiceOver are set in the simulator's Settings app (Accessibility).

- **Dev build lies about speed:** judge frame times only in a release build on a physical device; a Reanimated worklet that is smooth there can drop frames in the dev build.
- **Types of states:** drive demo states with a launch constant or Expo `extra` config, not a runtime environment variable on the simulator.
- **Component tests:** `@testing-library/react-native` for the states (loading, empty, error), accessibility labels (`getByRole`, `getByLabelText`) and that the reason text appears once; mock `react-native-reanimated` with its own jest setup and `useReducedMotion` to test the Reduce Motion path.
- **Native conformance:** native-stack swipe-back works, large title collapses with the scroll, tab bar stays on push, `Text` scales at the largest accessibility size (no `allowFontScaling={false}` on content), dark mode via `PlatformColor`.
