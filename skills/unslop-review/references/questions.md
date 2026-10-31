# Question bank

Not a UI checklist: a concept interrogation. A good question erases pixel work that never needed to exist. T1 uses the questions marked `[T1]`; T2 uses `[T1]` and `[T2]`; T3 uses all. The fixed block F1 to F6 runs on every tier. Answer each yourself, with `file:line`, before escalating.

## Existence
- **Q1 [T1]** If I deleted this today, who complains within 48 hours, and what do they do instead? "Nobody" kills the element; "they open a spreadsheet" means the screen lost.
- **Q2 [T1]** Does this exist because someone needs it, or because the data was available? Available data is raw material, not a reason.
- **Q3 [T2]** What is the one-sentence version of this? Why is the screen better than the sentence?
- **Q4 [T3]** What is the smallest number of screens that delivers this result? Why isn't it that number?

## Decision
- **Q5 [T1]** What decision does this produce? Write the sentence the user says after looking. If it is "ok", it is a report, not a tool.
- **Q6 [T1]** What is the number that decides, and is it the heaviest element on screen?
- **Q7 [T2]** Is this the answer, or the raw material of the answer? If the user still needs a calculator, the interface did half the work.
- **Q8 [T2]** What default did you pick for the user (sort, filter, period, preselected plan), and can you defend it in writing? A default is a decision made for the user.
- **Q9 [T3]** Model the user's optimal play. Does it pay the business?
- **Q10 [T3]** Where is the limit that motivates an upgrade, and does it appear at the moment it is hit, not as an interruption?

## Data truth
- **Q11 [T1]** In which scenario does this number lie? Classics: a failed fetch painted as zero; a zero denominator shown as "0,0%"; a stock (balance, queue) filtered by a date meant for events; budgeted and actual side by side with no label.
- **Q12 [T2]** If the backend goes down, does this show an error or a zero? Verify by running with the backend stopped. The service often swallows the error one layer down, so the error state is unreachable.
- **Q13 [T2]** What promise does this make that the backend does not back? (A price typed in copy while the server charges another; a status label that is not the status.)
- **Q14 [T3]** If the optimistic write fails, what gets recorded and what does the user see?
- **Q15 [T3]** Does the person seeing this control own it, or just hold a role?

## Attention
- **Q16 [T2]** How many vertical points until the first real data? Chrome is a budget.
- **Q17 [T2]** Where will this element be missing? Run it with the best record and the worst. An element missing exactly on the best records is worse than none.
- **Q18 [T2]** What does this teach the user to do wrong? Color on everything teaches that color means nothing; a badge on 100 percent of rows teaches people to ignore badges; a disabled primary teaches that the button lies.
- **Q19 [T3]** If this is the only screen the customer sees, do they renew? Latency and rhythm are retention features.

## Product, scope and positioning
- **Q20 [T3]** Which feature do I kill to open room for this one? Hiding solves what deleting does not need to.
- **Q21 [T3]** Who is this screen for, by role? A screen serving two roles serves both badly.
- **Q22 [T3]** If a competitor copies this pixel for pixel tomorrow, what remains that is ours?
- **Q23 [T3]** Is the promise the size of the proof? Proof that arrives after the doubt arrives late.
- **Q24 [T3]** Do landing, onboarding, product and pricing say the same sentence?
- **Q25 [T3]** Is this a category error: is the thing the brand, or the app?

## Cost and future
- **Q26 [T2]** Who maintains this in six months, and how do they find out it broke? A defect that is a pattern should become a test that sweeps for the shape.
- **Q27 [T3]** If I charged for this, how much? If "nothing", who pays the maintenance?
- **Q28 [T3]** Which decision of this audit will I regret in three months? Last question, always; write it in the report.

## Fixed block F1 to F6 (every tier)

- **F1 Reinventing the wheel?** Search the project, the framework (Cupertino widgets, native-stack, native HTML elements) and one validated package before accepting a hand-rolled widget. List what was reused and what was written new, with the search that justified each new one. A formatting, date, currency or status helper inside a widget is an alarm.
- **F2 Design system consistent?** Tokens, not raw colors. Shared widgets, not copies. Same label, radius and spacing as the neighboring screen. Compare side by side with the exemplary widget in the same folder; a divergence becomes a fix on the target or a proposal on the exemplar, never a third variant.
- **F3 Responsive and fast?** Measured, not eyeballed: smallest and largest iPhone, an iPad if shipped, largest Dynamic Type, landscape if supported; on web 320 to 1440 px and 200 percent zoom. Overflow shows as `RenderFlex overflowed` in the console and yellow-black stripes. Performance has a number: frame times in profile mode on a physical device, never the simulator or debug.
- **F4 Flow progressive for the user?** Walk the whole flow, not the screen: how you arrive, what you do, where you go next. Write it as numbered steps, mark where the user discovers value, name where they drop off. If the target user is not named by role, that is the answer.
- **F5 What can we hide, compact or turn into an icon?** A table: hide / compact / icon, plus what must not be hidden and why. Every row names the points of height it gives back. An icon only counts with an accessible label and a universal meaning.
- **F6 What is missing for a polished iOS product?** Mark each of these done, missing or not applicable, then name the three with the most leverage per effort and stop:
  1. Every action reachable by VoiceOver and Switch Control; labels read well
  2. Tap targets at least 44 pt
  3. Zero layout shift between loading and loaded (skeleton with the final shape)
  4. Optimistic write with undo, never a confirm dialog for a reversible action
  5. Loading, empty and error are three different states, and empty makes a case
  6. Nothing lies: no silent zero, no zero denominator, no label that is not the status
  7. Perceived latency handled where it is born
  8. Motion under 300 ms where the finger waits, interruptible, and Reduce Motion respected without losing the result
  9. Dynamic Type reflows to the largest size without clipping
  10. Dark mode and increased contrast both look designed, not inverted
  11. One primary action per screen; a disabled primary does not exist
  12. The screen returns to the same place after acting
  13. Copy is plain, and error messages say what to do

## Declutter test (for "too much text", "cluttered", "template look")

Does this survive if I delete it? If people find out by using it, delete it. Discovering that a card drags costs one gesture; reading that it drags costs a line forever.

1. Count the text blocks before the first real content. More than three: the screen is explaining itself.
2. Read the title, the intro and the first label in sequence. If all three say the same thing, two die.
3. Count the pieces lit with the accent at once. More than one per region: it highlights nothing.
4. Count the entry points of the same kind (two URL fields, two search bars). Two: one goes, or the names state the difference.
5. Count tags, chips and dividers. Delete them all; whatever you miss comes back.
6. Shrink a screenshot to 50 percent. Whatever became texture goes.

Two legitimate exceptions only: a gesture with no visible affordance (a modifier, a shortcut), and an order that carries meaning (`01 source -> 05 output`, not `1. 2. 3.` on a feature list). Write the reason on the line.

## How to report an answer

```
Q7 Is this the answer or the raw material?
   Raw material. The two cards deliver two totals and neither says which regime
   costs less (tax_card.dart:60, summary_card.dart:79). The comparison is the work
   and the user is doing it in their head.
   FORCES: a verdict line at the top, or merge the two cards. User's call; it changes scope.
```

A question without evidence does not go in. An answer that forces nothing leaves the report; an interrogation that ends in "everything is fine" did not interrogate.
