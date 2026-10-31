# Score and report

## The score (100 points, three bands)

| Band | Points | How it scores |
| --- | --- | --- |
| Gate (`slop-grep.sh`, the stack's analyzer and tests) | 20 | all or nothing. Any analyzer error or confirmed gate defect in the target drops the 20. A gate that was skipped scores 0 and is written down. |
| Judgment | 40 | 2 x the sum of the five native dimensions below (each 0 to 4, so 20 maximum) |
| Interrogation | 40 | proportional to the tier's questions answered with `file:line` evidence, plus the fixed block F1 to F6. A question answered with an adjective does not count. |

### The five judgment dimensions (score each 0 to 4)

Every confirmed slop sign, platform violation or state gap lands in the dimension it hurts; a dimension scores 4 only with no confirmed, unfixed item in it.

| # | Dimension | Check for | 0 | 4 |
| --- | --- | --- | --- | --- |
| 1 | Accessibility | missing labels, reading order, text scaling defeated by fixed sizes, targets under 44 pt, Reduce Motion ignored, contrast failing in either appearance | screen reader unusable | labeled, ordered, scales cleanly, Reduce Motion honored |
| 2 | Performance | work before first frame, unvirtualized long lists, jank in scroll or gesture paths, wasted rebuilds, full-size images for thumbnails, blur or glass in large areas | janky everywhere | fast launch, smooth scroll, lean |
| 3 | Appearance and theming | hard-coded colors, broken dark or high-contrast appearance, off-platform hand-rolled materials, the slop signs of color, type, icons, spacing, copy | hard-coded everything | semantic throughout, both appearances first-class |
| 4 | **Platform conformance (critical)** | broken system gestures, inset violations, off-platform navigation, web-shaped controls, icon-set drift, ported patterns | web port, nothing native | a fluent iPhone user trusts every screen |
| 5 | Adaptivity | stretched phone layouts on iPad, orientation breakage, keyboard hiding inputs, multitasking sizes, no size-driven structure | one size only | adapts across sizes, orientations and windowing |

Rating of the dimension sum: 18 to 20 excellent, 14 to 17 good, 10 to 13 acceptable, 6 to 9 poor, 0 to 5 critical. Keep P3 findings few.

**Why the gate is worth little.** In the first real round of the audit this is based on, the gate scored zero before and zero after a refactor, and every one of the twelve slop items was caught by judgment. The gate has veto power and almost no discriminating power, so it is worth 20, not more.

Reading the score:

- **Below 70**: does not go to PR. Gate defect or confirmed slop with no fix.
- **70 to 89**: goes to PR with the open items listed and an owner named.
- **90 or more**: passed. A pending product decision still goes at the top of the report, not the bottom.

A high score with verification missing is not a high score. What did not run goes in as an explicit deduction. A T3 target with no positioning interrogation is an incomplete audit regardless of the number.

## Template (`AUDIT.md`)

```markdown
# Review: <target>

**Disposition** fix · **Tier** T2 screen · **Score** 78/100 · **Evidence** simulator only (iPhone SE, 15 Pro Max; light, dark, largest text)
**Platform conformance verdict:** FAIL, reads as a ported Android screen: Material FAB (home_screen.dart:41), drawer (app_shell.dart:12), ripple on rows.
**Surface** B work (the variable it moves: decision quality, throughput)

## Pending decision (the user's, not mine)

1. <the question that changes scope, with my recommendation first>

## Diagnosis in one sentence

<the single central problem; if it takes a paragraph it is not done>

## Surface table

| Screen or element | Surface (A/B/C) | Business variable |
| --- | --- | --- |

## Screens seen

| Screen | Device and size | State (data, empty, error, dark, text size, Reduce Motion) | What happened |
| --- | --- | --- | --- |

## Gate

| Check | Before | After |
| --- | --- | --- |
| slop-grep candidates confirmed | 9 | 0 |
| flutter analyze | pass | pass |
| smallest phone, largest text | overflow 18 pt | none |

Skipped: <none, or which and why>

## Judgment (0 to 4 each; 2 x sum = judgment points)

| Dimension | Score | Key finding |
| --- | --- | --- |
| Accessibility | | |
| Performance | | |
| Appearance and theming | | |
| Platform conformance | | |
| Adaptivity | | |

## Findings, P0 first

Each: what is wrong · why (principle and the variable it costs) · fix with real widget names · `file:line` · severity (would a user contact support? then at least P1).

## Slop fixed

| # | Sign | Where | Fix |
| --- | --- | --- | --- |
| 1 | Rainbow card | breakdown_card.dart:66-160 | color became the exception; a typographic minus marks outflow |

## Slop kept on purpose

| Sign | Where | Why it stays |
| --- | --- | --- |

## What NOT to change

The subtle correct decisions a careless rewrite would destroy, each with why.

## One real tension

Cost, the options with what each loses, a recommendation, and a trigger to revisit.

## Interrogation

Q5 <question>
   <answer with file:line>
   FORCES: <what changes, or "nothing">

### Fixed block
F1 reuse · F2 design system · F3 responsive and performance · F4 flow · F5 hide or icon · F6 what is missing (thirteen marked, top three named)

## What this round fixed in the detectors

Required, even if empty. A false positive fixed in `slop-grep.sh` goes here with the case locked in `scripts/fixtures/`; a false negative too, and that one is the serious one.

| Rule | Was flagging | Fix | Fixture case |
| --- | --- | --- | --- |

## Taste proposal (the user picks line by line)

| Key | Before | After |
| --- | --- | --- |

## Not verified

- <what did not run, and what it would take to run it>

## Questions

2 to 4 questions that reference specific findings, each with 2 or 3 concrete options; or `Questions skipped: <reason>` when fewer than 3 priority issues were listed. Nothing after this section.
```

Place it at `docs/audits/review-<target>-<YYYY-MM-DD>.md`, or wherever the repo already keeps audits. Disposition, score and the pending decision come first; whoever reads it is deciding, not studying. For a re-review after fixes, score each prior material fix resolved, partial or unresolved from what the new screenshots visibly show (a fix answered mechanically, positions moved but the quality the finding named still absent, is partial at best), name at most three regressions the fix batch introduced, and recompute the disposition; unresolved or partial findings can never recompute to `ship`.
