# Flutter verification

```bash
flutter devices                                  # pick a simulator or device
flutter run -d <id>                              # debug, for iteration
flutter run -d <physical-device-id> --profile    # frame times; never judge speed in debug or the simulator
flutter analyze && flutter test
bash ~/.claude/skills/unslop-review/scripts/slop-grep.sh --stack flutter lib
```

Dedicated simulator and states (Xcode command line):

```bash
xcrun simctl create "MyApp Test (iPhone 17)" "iPhone 17" <runtime-id>   # list ids: xcrun simctl list runtimes devicetypes
xcrun simctl boot <udid> && flutter build ios --simulator --debug --dart-define=NOW=6.2
xcrun simctl install <udid> build/ios/iphonesimulator/Runner.app && xcrun simctl launch <udid> <bundle-id>
xcrun simctl io <udid> screenshot shot.png
xcrun simctl ui <udid> appearance dark                                        # also: light
xcrun simctl ui <udid> content_size accessibility-extra-extra-extra-large     # largest Dynamic Type; back: large
xcrun simctl ui <udid> increase_contrast enabled                              # also: disabled
```

Reduce Motion, Reduce Transparency, Bold Text and VoiceOver are set in the simulator's Settings app (Accessibility).

- **Overflow:** watch the console for `RenderFlex overflowed` and yellow-black stripes. Log `MediaQuery.sizeOf` and `textScalerOf` to confirm the size.
- **Motion feel:** `timeDilation = 4.0` (`package:flutter/scheduler.dart`) in a debug build, capture a mid-transition frame.
- **Widget tests:** `tester.hasRunningAnimations` for Reduce Motion and settle checks; `tester.view.physicalSize = Size(402*3, 874*3)` with `devicePixelRatio = 3` so a test need not scroll; `MediaQueryData(disableAnimations: true)` to emulate Reduce Motion (the platform-dispatcher flag is overridden by an explicit `MediaQuery`); `TextScaler.linear(3.1)` for the largest text; `find.bySemanticsLabel` for the screen-reader label.
- **Compile-time demo states:** `--dart-define=NAME=value`, read with `String.fromEnvironment` / `int.fromEnvironment`.
