# Data elements: charts, meters, tiles, simulators, panels

The decision to include an element is made elsewhere: it must name the variable it moves (what decision or action it supports), or it goes. This file says how a kept element is drawn, so they read as one family. Source: visant-refine and visant-frontend (MIT), plus Impeccable's cognitive-load rules.

**Refine never justifies an element.** If "which variable does this move?" has no answer, delete it. A beautiful chart of a number nobody uses is slop with better finishing and costs more attention than the ugly version.

## The shared anatomy

Every data element carries four roles in the same visual order:

| Role | What it is | How it shows |
| --- | --- | --- |
| label | what is measured | footnote style, secondary color, sentence case |
| value | the number that decides | heaviest weight in the block, tabular figures, neutral color |
| qualifier | the ruler that gives the value meaning (limit, goal, period, base) | footnote style, next to the value |
| evidence | the shape that shows the value against the ruler | bar, gauge, sparkline, band |

- **Color is the exception.** One neutral; color only for a real exception (over a limit, overdue, negative). Text uses a text role, never the series color. Color follows the entity (this plan is always amber), never the ranking position.
- **No number without a ruler.** "$25,201" says nothing; "11.3% of gross revenue" does.
- **No denominator, no ratio.** A zero denominator is null and the line does not render. "0.0%" states a false fact.
- **A shape is valid only inside its domain.** A ratio bar has a scale while the value fits the limit; past it the bar saturates and lies, so replace it with the number that says how far it went.
- **Loading, empty and error are three designed states** for every chart and every list.
- **Same family at both ends.** When you add the second element of a kind, extract the first; two variants of the same thing is the start of three.
- Stock versus flow: a stock (balance, queue, pipeline) takes no date filter; two numbers of the same unit but different kinds (budgeted and actual, estimated and logged) always carry labels saying which is which.

## Catalog

- **Limit meter:** value as percent of the ceiling, ceiling written once (header or qualifier), bar only while at or under 100 percent; above it show the overrun as a number. Color only when it overran; "yellow at 80 percent" is opinion unless a different action exists at 80.
- **Metric tile:** a hero number with context; one per surface carries weight (two of equal weight become none); zero does not render a tile, it renders a one-line empty state; without the qualifier it is a loose number. Impeccable refuses the "hero-metric template" (big number, small label, supporting stats, accent) as a page structure; on a working screen the figures that decide something are fine, as scaffolding for a marketing screen they are slop.
- **Sparkline:** no axis, grid, tooltip or legend; fixed height 24 to 40 pt; fewer than four points is not a trend, write the delta; without an axis it can never be the only source of a number.
- **Change badge:** signed delta plus what it compares to (`+12% vs last month`); no base means no delta (a zero base is null, never "+100%"); direction icon plus number, never color alone.
- **Ratio gauge:** only for a closed ratio between 0 and 1; the number in the center, the arc is evidence; a half arc reads better in a short card; past 1 it becomes a limit meter.
- **Regime band:** a segmented scale for tiers; cuts shown as numbers on the track; the current band named in words; a band the value already excluded stays visible, marked unavailable.
- **Verdict line:** one sentence above a group of cards saying what they mean together, when the user was comparing in their head. One number, no color unless exceptional; if it depends on data not on screen, say so; if it is a hypothesis, use that word.

## Charts

- Series colors come from semantic roles (single series: the tint; comparison with the past: secondary label; exception: the destructive color; goal hit: the positive color); grid and axis are recessive. More than two series on a working screen means the question was not decided: cut series or split the chart. Never two y axes.
- Every chart sits inside a state wrapper (skeleton shaped like the bars, an empty state that speaks, an error with retry). An empty framed axis is the chart's "0 items".
- A limit or goal is a labeled dashed reference line, not a background color; the line carries the name. Mark where it crossed, not only that it crossed (the month it passed the ceiling is what triggers action). Cumulative-crossing-a-band is the right form for "when do I go over", not a pie, per-period bars or a gauge.
- Colors resolve in context (dark mode): resolve at build time with the context, never cache a resolved color in a static.
- Check an empty period, a single point and a long label; render and look. Measure at the smallest iPhone: charts are the main source of horizontal overflow.
- Hover and press on a point or bar change color and opacity only, 100 to 150 ms. A chart entrance on first mount is short (200 to 300 ms) and plays once, never on every rebuild; a value the user already read on the previous screen does not animate again.

## Simulation sliders (a projected scenario next to facts)

A slider that projects a scenario puts a number on screen that did not happen. Contract:

1. The real value stays visible and marked on the track; the labels say which is which (real and simulated).
2. An active simulation is a visible state (a label on the block), and back to real is one tap that only shows while simulating.
3. Stops at the numbers that change the decision (a regime ceiling, a bracket), not round multiples; the cuts are drawn on the track with their numbers before the user drags.
4. Nothing persists: a simulation never writes to the database; a shared link says it is a scenario; changing context discards it.
5. A meaningful range (the next cut, double the real value), not 999999. `Semantics(value:)` speaks the formatted value, and the control is reachable by keyboard and VoiceOver.
6. The number follows the finger: no debounce, no animation while dragging, no fetch per movement. After release, the recalculated total may count up once. State is one nullable value (`null` means no simulation), so "back to real" is `sim = null` and there is no equality test on floats.
7. A slider is a projection, not a filter; swapping them makes people think they deleted data.

## Panels (settings, inspectors, editors)

Choose the control from the shape of the data:

| Data | Control | Not |
| --- | --- | --- |
| 2 to 5 short options | segmented control | a picker that hides options that would fit |
| 6 or more options, or long labels | a picker or a push to a list | a segmented control that truncates |
| on/off that reveals more | a switch, and the dependent controls appear only while on | a control visible but dead |
| a point in 2D (anchor, alignment) | a 3 x 3 grid | two pickers |
| a vector (scale, per-side padding) | one row of fields with a lock for uniform | three stacked sliders |
| a bounded number | the row is the slider: label left, value right | a slider under a separate label |
| an unbounded or precise number | a field (type, step) | a slider with an invented maximum |
| a color | swatch plus value; system color picker for custom | a bespoke picker |
| a gradient or a curve | the picture, editable in place, plus exact numbers | N rows of "Color k / Stop k" |
| an ordered list | header with add, each row with its own remove, reorder | add and remove buttons at the end (remove which?) |

Cover the labels: if the shapes still say what they edit, the panel is designed. Row anatomy: label left (muted, no colon), value right in tabular figures, unit one tone dimmer, a normalized display (`0.40s`, never `0.4s` then `0.45s`), one row height. The chrome follows the state: reset appears only after something changed and only for its group, conditional controls exist only while they apply, rare actions sit behind one menu, help is on demand (not a caption under every control), and depth comes from lines and tone, not boxes inside boxes.

## Cognitive load (check every dense screen)

At most about four items per group; at most four visible choices at a decision point (five to seven pushes it, eight or more is overload: group them, highlight the recommended one, disclose the rest); one primary action and one or two secondary, the rest in a menu; show current location; do not make the user remember a previous screen's information; co-locate what one decision needs. Failing four or more of these is high cognitive load.
