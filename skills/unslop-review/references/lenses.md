# Review lenses

Optional lenses for T2 and T3 reviews. They answer different questions than the sign catalog, so use them when the review is about whether the screen works for people, not just whether it looks generated. Sources: Impeccable critique (Nielsen heuristics, cognitive load, personas, severity) and visant-frontend critique.

## Design specificity verdict (do this first, before reading any scanner output)

Does the result feel authored for this product, or category-interchangeable? Cover the product name: could another product ship this screen unchanged? Judge composition, interaction and visual language before the scanner's findings enter your context, because deterministic output anchors judgment. Run the swap test on copy and the template test on layout.

## Design health score (Nielsen's 10 heuristics, 0 to 4 each)

Be honest: a 4 means genuinely excellent; most real interfaces land between 20 and 32 of 40.

| # | Heuristic | Check for | 0 means | 4 means |
| --- | --- | --- | --- | --- |
| 1 | Visibility of system status | loading, confirmation, progress, current location, inline validation | the user is guessing | every action confirms, progress always visible |
| 2 | Match with the real world | plain terminology, natural order, recognizable icons | pure jargon | speaks the user's language throughout |
| 3 | User control and freedom | undo, cancel, back, easy clear of filters | trapped | undo, cancel, back and escape everywhere |
| 4 | Consistency and standards | same words, same actions, platform conventions | different products stitched together | cohesive and predictable |
| 5 | Error prevention | confirm destructive actions, constraints, smart defaults, draft recovery | errors easy to make | errors nearly impossible |
| 6 | Recognition rather than recall | visible options, labels on icons, recents | heavy memorization | everything discoverable |
| 7 | Flexibility and efficiency | accelerators, bulk actions, shortcuts | one rigid path | multiple paths and power features |
| 8 | Aesthetic and minimalist design | only necessary information, clear hierarchy | everything competes | every element earns its pixel |
| 9 | Recognize, diagnose, recover from errors | plain language, names the problem, suggests the fix, preserves input | cryptic or none | pinpoints, fixes, keeps the user's work |
| 10 | Help and documentation | contextual, task-focused, concise | none | the right info at the right moment |

Score the heuristics that apply; mark any that genuinely cannot apply to the surface as `n/a` with a one-line reason (7 and 10 often on onboarding or paywall screens) and renormalize the maximum (24 of 32, not 24 of 40). Read the band from the percentage: 90 percent or more excellent, 70 good, 50 acceptable, 30 poor, below that critical.

## Cognitive load checklist (count failures)

Single focus; chunking (four items or fewer per group); grouping by proximity; clear visual hierarchy; one decision at a time; minimal choices (four or fewer visible options at a decision point); no demand on working memory across screens; progressive disclosure. 0 to 1 failures is low load; 2 to 3 is moderate; 4 or more is critical. Typical violations: the wall of options, the memory bridge, hidden navigation, jargon, visual noise floor (everything the same weight), inconsistent patterns, multi-task demand, context switching.

## Personas (walk the primary action as each; report named elements, not generic worries)

| Persona | Profile | Red flags to hunt |
| --- | --- | --- |
| **Alex**, impatient power user | expert, wants efficiency | forced unskippable onboarding, slow animations that cannot be skipped, one-at-a-time flows where batch is natural, redundant confirmations for low-risk actions |
| **Jordan**, confused first-timer | never used this kind of product | icon-only navigation, jargon, no visible help, ambiguous next step after an action, no confirmation that it worked |
| **Sam**, accessibility-dependent | VoiceOver, Switch Control, keyboard, low vision, up to 200 percent text | unlabeled controls, color-only meaning, custom components that break VoiceOver flow, missing focus, time-limited actions |
| **Riley**, deliberate stress tester | edge cases, long strings, emoji, offline, backwards navigation | silent failures, technical errors, empty states with no guidance, lost data on interruption, inconsistent similar interactions |
| **Casey**, distracted mobile user | one thumb, interrupted, slow connection | primary actions at the top, no state preserved after an interruption, big text inputs where a selection would do, heavy assets, tiny targets |

Selection: marketing or paywall: Jordan, Riley, Casey. Dashboard: Alex, Sam. Checkout: Casey, Riley, Jordan. Onboarding: Jordan, Casey. Data-heavy: Alex, Sam. Form or wizard: Jordan, Sam, Casey. Only add a project-specific persona when the direction file gives real audience data; never invent audience details.

## Severity (P0 to P3)

| Level | Name | Meaning | Action |
| --- | --- | --- | --- |
| P0 | Blocking | prevents task completion | fix now |
| P1 | Major | significant difficulty, confusion or a platform-guideline violation | fix before release |
| P2 | Minor | annoyance with a workaround | next pass |
| P3 | Polish | no real user impact | if time permits; keep these few, a long tail buries what matters |

Unsure between two levels: would a user contact support about it? If yes, it is at least P1. Every finding states what is wrong, why (the principle and the variable it costs), the concrete fix with real widget names from this project, and `file:line`. A finding that cannot name the variable it costs is a preference: cut it or label it taste.

## Report shape that is safe to act on

1. Diagnosis in one sentence (if it takes a paragraph, it is not done).
2. Findings, P0 first.
3. **What NOT to change:** the subtle correct decisions a careless rewrite destroys (a local set that decouples the user's rhythm from network latency; a key that forces a remount so draft state does not leak between records). This section is not padding.
4. **One real tension:** a recommendation that has a genuine cost. State the cost, the options with what each loses, a recommendation, and a trigger to revisit ("if after three real sessions people stop reading it, the box comes back").
5. Tone: direct, specific, no preamble, no flattery, no "consider exploring". Findings are about the code, never about the person who wrote it.

## Closing the review

End with two to four questions that reference specific findings and offer concrete options (which area first, was this tone intended, how much scope, anything off limits), or the literal line `Questions skipped: <reason>`, allowed only when fewer than three priority issues were listed. A review that ends with neither the questions nor the skip line is incomplete. Put the question last: nothing after it.
