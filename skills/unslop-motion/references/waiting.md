# Waiting is a surface

Every moment the user waits has motion on it, designed or not. A bare spinner is the default nobody chose. Waits are rare-frequency, so this is where the delight budget lives: a character, a loop worth watching. (Source: visant-motion section 4, HIG 8.2 and 8.8.)

## Pick the treatment by how long the wait is

| Wait | Design it as | Never |
| --- | --- | --- |
| under 100 ms | nothing: apply the change optimistically, offer undo | a spinner (it only flashes) |
| 100 to 300 ms | the current UI holds; the press feedback already answered | swapping the surface for a loader |
| 0.3 to 1 s | skeleton in the final layout, then cross-fade to content | spinner; layout jump on arrival |
| 1 to 5 s | skeleton plus progressive reveal; a determinate bar only if the percent is real | fake progress that parks at 90 percent |
| 5 s and more | narrate the step running now, plus an illustration or calm loop; offer an out past 10 s | one static spinner for a minute |
| unknown | stream partial results: content arriving is the loader | indeterminate anything |

## Rules

1. **Answer the tap before the server does.** Press feedback plus an immediate state change is frame one of loading. An optimistic write with undo beats every spinner. If the surface closes on tap, an in-button spinner can never show: delete it, with the `submitting` state it left behind.
2. **Anti-flicker pair.** Do not show a loader before 300 ms; once shown, keep it at least 500 ms. A loader that blinks reads as a bug.
3. **Skeleton equals the real layout** (same box sizes, radius, gaps, and the same columns), or you trade a spinner for a layout jump. Do not skeleton text you cannot size (variable-length titles: one fixed bar).
4. **Never hard-swap skeleton for content.** Cross-fade at `base`; at most a 4 pt rise on the first block only.
5. **Shimmer** is `linear`, 1.2 to 1.6 s, translating a gradient with a transform (never repainting a background each frame), low amplitude, and a static tint under Reduce Motion. It is the one legitimate infinite animation, because nothing ever interrupts it.
6. **Skeleton to error is the forgotten branch.** Swap the skeleton for the error in place, keep the box, put Retry inside it, same cross-fade, no bounce, no red flash. An error is information, not a jump scare.
7. **An empty state is a wait too**, waiting on the first data: say what will appear and give the one action that ends the wait.
8. **One waiting animation per surface.** Skeleton rows plus a spinner plus a progress bar is three answers to one question.
9. **The entrance must not cost more than the wait.** A 400 ms reveal on a 200 ms fetch means you built the latency yourself.
10. **Progress is linear and never runs backward.** Clamp instead.
11. **Reduced motion:** shimmer becomes a static tint, a looping illustration becomes one frame; the progress readout and step labels stay, because they are information.

The anti-flicker pair as code: Flutter `stacks/flutter-recipes.md` (`DelayedLoader`), React Native `stacks/react-native.md`, web `stacks/web.md`.
