---
name: unslop-review
description: Use when auditing a finished or in-progress screen, page or flow (iOS app in Flutter, React Native or SwiftUI, or a web page or app) before a PR or release, when asked whether UI "looks AI-made", "is slop", or "is ready", or when a screen passes lint and tests but still feels templated, cluttered, or untrustworthy.
license: MIT
---

# Unslop Review (iOS-first mobile, and web)

An adversarial audit. The screen is the defendant, not the client. Two halves that do not replace each other: a **gate** (grep and analyzer, deterministic) and **judgment** (you, with the slop catalog, the native conformance dimensions and a tiered interrogation). AI slop survives any linter, because the defect is a decision, not syntax.

**Core principle.** A green gate is not a seen screen. What compiles is not what someone saw. Never report a score, a verdict or "looks good" for a screen you have not built and looked at. You are the last gate before the user: calibrate against the quality bar, never against the effort visible in the build.

Built on visant-killer (MIT, Visant), Impeccable's native audit and critique (Apache-2.0, Paul Bakaus) and the unslop sign catalog (CC BY 4.0, Damir Sokolovsky), adapted to iOS-first mobile (Flutter, React Native, SwiftUI) and the web. See `references/credits.md`.

**REQUIRED BACKGROUND:** `~/.claude/skills/unslop-design/` (its `references/signs.md`, `platforms/ios.md` or `platforms/web.md`, and `data-elements.md` are what you judge against) and `~/.claude/skills/unslop-motion/` (motion rules).

## When to use

- Before a PR or release that touches UI
- "Does this look AI-made?", "audit this screen", "is this ready?"
- After running unslop-design or unslop-motion, to check what survived

Not for: fixing a screen from scratch (unslop-design), writing an animation (unslop-motion), correctness bugs unrelated to UI (a code review).

## Step zero: platform and stack

Detect from the project (`pubspec.yaml` Flutter; `package.json` with `react-native` or `expo` React Native; Swift sources SwiftUI; HTML, CSS or a web framework web) and say which you picked. It decides the scanner's `--stack`, the commands in `references/stacks/<stack>.md`, and which conformance verdict you write in step 4. Everything else is identical.

## Steps

### 0. Roots first (large target)
If the target is dozens of files, find the shared components first (theme, buttons, list rows, cards, layout wrappers). One wrong shared widget produces hundreds of leaf symptoms in the wrong files. Fix roots before leaves.

### 1. Classify the target (never skip)

| Tier | Target | Interrogation |
| --- | --- | --- |
| T1 Leaf | one widget, card or row | the 5 questions marked T1 |
| T2 Screen | a whole screen with states and navigation | T1 plus T2 questions (12) |
| T3 Core | money, identity, permissions, onboarding, or a multi-screen flow | all questions plus positioning |

A mixed target is classified by region (a billing row inside a list screen is T3 inside a T2). A complaint only about excess ("too much text", "cluttered") goes to the declutter test in `references/questions.md`.

### 2. Gate (before reading the code)

```bash
bash ~/.claude/skills/unslop-review/scripts/slop-grep.sh [--stack flutter|rn|web] <dir>   # candidates, never verdicts; the stack is auto-detected
# plus the stack's analyzer and tests: flutter analyze && flutter test | npx tsc --noEmit && npx eslint . | the web lint and an axe or Lighthouse run
```

Run what the project already has too: look at the manifest (`pubspec.yaml`, `package.json`), lint config, `scripts/` and CI for lint, design-token or golden checks; run them on the target, not the whole repo (old debt drowns the new finding), and record what ran and what was skipped and why. A skipped gate is never a pass.

Open `AUDIT.md` (`references/report.md`) and fill its **surface table** before fixing anything: per screen or element, the **surface** (A acquisition, B daily work, C trust: money, permission, destructive action) and the **business variable** it moves. A blank or "TBD" variable means the step was skipped.

Confirm every gate finding at `file:line` before changing anything; legacy code is noisy. **If a rule produces many hits and almost none are real, the rule is wrong:** group hits by folder, read the rule's declared intent, scope the rule to it with a reason written inside the rule, add the case to `scripts/fixtures/` in both directions (a false negative is the serious one: a gate that says zero about code it never read looks like success), then fix what is left. Never silence it in app code. A genuine exception goes on the line: `// EXCEPTION to slop-grep/S05: <reason of at least 8 letters>`, on the same line or up to 8 lines above, naming the exact rule; mute allowlists are forbidden. Re-record a CI baseline only when the total dropped.

### 3. Verify on a running app (before judging)

Build it and look (`references/verification.md`, then `references/stacks/<stack>.md`). Whatever did not run goes in the report as a deduction. **Evidence must be valid before it counts:** the screenshots exist for every shipped device class and appearance, show what their filename claims (no blank or half-loaded screens, document top visible), and say whether they came from the simulator or a physical device. A finding raised without its checks is a suspicion, not a defect. If evidence is missing or malformed the disposition is `recapture` and nothing else is binding.

### 4. Judgment: platform first
Write the **platform conformance verdict first**, pass or fail. Mobile: does this read as a native iOS app or a ported website or Android app? List the specific violations without softening (hamburger drawer, ripple, Material FAB, custom back, web-shaped controls, hover-dependent affordances, mixed icon sets, off-system materials). Web: does this read as a considered web page, or as the default AI landing page, and does it pass the basics (semantic HTML, keyboard and focus, 200 percent zoom reflow, reduced motion, no layout shift)? List the specific violations without softening. Then score the five dimensions and the slop signs (`references/report.md`). Read `~/.claude/skills/unslop-design/references/signs.md`; every confirmed sign that survives with no fix and no accepted justification lowers the dimension it hurts.

For T2 and T3 also apply `references/lenses.md` (design specificity verdict first, then heuristics, cognitive load, personas).

### 5. Interrogation
Questions by tier from `references/questions.md`; the fixed block F1 to F6 runs on every tier. Answer each yourself with `file:line` evidence first; a question handed back with no attempt is laziness dressed as rigor. Only what changes what gets built and the code cannot answer goes to the user, with your recommendation first. One question that kills the screen beats twelve token fixes; if the honest answer is "this screen should not exist", write that.

### 6. Report
`AUDIT.md`, disposition word and score first, never just chat text. Template and scoring: `references/report.md`.

## Disposition (exactly four words, derived not felt)

`recapture` when evidence failed; `rebuild` when fidelity or concept failed wholesale (list the regions to re-derive and the assets to produce); `fix` when any material fix is open; `ship` only when nothing material is open. A page a design director would send back is `fix` at best however functional it is. A `ship` earned after a fix round covers the scored fixes, not the whole surface; say so. Prefer a fresh context for the review when the user allows a subagent; otherwise say the review ran in the same context as the build.

## Rules

- Only the fix of a confirmed defect goes into the file. What passes clean stays untouched, even if it reads flat. Taste improvements go as a proposal table; the user picks line by line.
- Report before and after of copy as the text itself, never a summary of it.
- "I improved the hierarchy" is not a finding. Say which element went up, which went down, and what it moves.
- "Not verified" is never empty out of laziness; if it really is empty, write what ran to prove it.
- A high score with verification missing is not a high score.
- Do not create new shared components without permission. Reuse and parametrize; look at the project, then the framework's own components, before adding one.
- Do not open a route that charges, spends credits or deletes data on load without a test account or a stub; say which was used.
- When fixing a systemic defect (a banned pattern, not a value), add a regression test that reads source and fails on the shape, with a sanity assertion that it scanned files, and test the exemption in both directions; a guard that scans nothing or whose allowlist swallows real hits is green and useless.
- Before rewriting a screen completely, list its defensive comments and carry each, or justify why not; record fixes found on a device in the direction file's Scars section.
- Do not declare done without having opened the screen. This is the line the whole skill exists to defend.

## Red flags: stop and go back

| Thought | Reality |
| --- | --- |
| "The gate is green, so it passes" | The gate catches syntax; slop is decisions. Verify and judge. |
| "I can tell from the code" | Overflow, clipped text and layout jumps exist only on a rendered screen. |
| "Empty state looks fine" | Empty hides every overflow. Run the worst record too. |
| "Backend works on my machine" | Run with it down. A silent zero is the dominant lie. |
| "The scanner said 0 hits" | Zero hits means the chrome is not repeated, not that the screen deserves its space. |
| "Taste fixes are quick, I'll include them" | Keep proposals apart so the user does not review the reviewer. |
| "The simulator looked fine" | Gestures, posture, haptics and frame times need a device; say which one produced the evidence. |
