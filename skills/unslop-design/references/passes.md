# Passes

Finish each pass across the whole screen before starting the next. Values live in `tokens.md`, platform rules in `platforms/<platform>.md`, code in `stacks/<stack>.md`. Numbers are points on iOS and the same numbers in px or rem on web.

## 1. Spacing

- Everything sits on a 4pt grid: paddings, gaps, fixed heights. A 2pt nudge inside a small control is fine; so is an odd value that exactly centers something.
- Same thing, same size. All rows in a list share one height and one gap; all cards in a row share one padding.
- Space shows grouping. Space inside a group is smaller than between groups, and each level at least 2x the one inside it (8 / 16 / 32). A label sits closer to its own items than to the section above.
- Things line up: icons in one column, labels on one start line, numbers aligned to the trailing edge.
- Padding follows density: compact 16, cards 20 to 24, page edges 16 to 20.
- Replace one-off values (`top: 13`, a 7-unit gap) with named steps from the project's spacing tokens.
- Respect safe areas (iOS) and the viewport (web: `env(safe-area-inset-*)`, `100dvh`). Never hard-code status bar or home indicator offsets.

## 2. Color

- Start from the platform's semantic colors, resolved dynamically: iOS `systemBackground`, `label`, `separator`, grouped backgrounds; web custom properties through `light-dark()`. Dark mode, increased contrast and elevated surfaces then work by construction.
- Three text roles: primary, secondary, tertiary (`label`, `secondaryLabel`, `tertiaryLabel`). Not ten slightly different greys.
- One accent, used rarely: the primary action, the selection, the one number that matters. Brand color becomes the accent and leaves the surfaces; no brand color means take it from the Direction's world.
- App surfaces stay neutral. The world shows in the accent, the charts and the moments. A screen whose background reads as orange, green or blue has gone too far (landing and onboarding screens may tint further).
- The moments are the exception: inside them color can be rich, as long as it stays inside the world and each color means something.
- Text on the accent needs 4.5:1. Darken the accent or use dark text.
- Semantic colors carry meaning only (green good, red error) and are toned to sit in the palette.
- Remove hue gradients, gradient text, colored glows and shadows, radial color washes, blobs and neon borders. A gradient is allowed only as a small tone shift inside one neutral.
- Borders are quiet hairlines (`separator`, or text color at 6 to 10 percent).
- Depth on dark comes from surface steps and hairlines, not shadows. On light, shadows are neutral, soft and small.

## 3. Icons

- Every emoji used as an icon or label decoration becomes a line icon from one set (the project's, otherwise SF Symbols on iOS or one open-source set on web).
- One size and one weight everywhere (20 to 24 in navigation, 16 to 18 inline).
- Icons take their text role color; they never get their own colors.
- The icon box has the same width in every row, and the gap to the label is fixed (8 or 12).
- Drop icons that add nothing (an emoji in every card title). Categories that need color get a small status dot.

## 4. Copy

- Headlines say what the product does for whom, in plain words, using facts already in the app.
- No exclamation marks, never `!!`. No greeting headlines (`Welcome back, Sam! 👋`); the title names the context (`October 2026`).
- Short labels: `Search`, not `Search anything...`.
- A change says what it compares to: `+12% vs last month`.
- Short strings (titles, labels, buttons, captions) end without a period; multi-sentence paragraphs keep theirs.
- No hype words (supercharge, seamless, unlock, magic, revolutionize, game-changing); no `AI-powered` on everything.
- Unverifiable claims (`Loved by 10,000+ teams`) are removed or made specific only if the user confirms. Ask and list them.
- Mock data looks real, never `[X]` or `123,456`.
- Badges like `PRO`, `New ✨`, `Beta 🚀` go away unless the product needs them, then quiet text.
- Error messages answer three things: what failed, why (when known and useful), and how to recover. Never an internal code as the headline, never a button label used as the error text, never a promise the system cannot keep.
- Destructive actions name the object and the consequence, and prefer undo over a confirmation when recovery is safe. When a confirmation is needed, name the action on the button (`Delete 280 leads`), not Yes or OK. Read counts from the authoritative source, not the paginated view, and say what it takes to get back.
- Empty states are of different kinds (first use, user cleared, no results, filtered out, no permission, failure); say which one and give the next useful action.
- Write the whole message so it can be translated (no concatenated fragments), leave room for 30 to 40 percent expansion, and keep variables structured.
- The fold names the task, not the state: ask which verb the person would type into search. "Find the right file without opening an editor", not "You have hundreds of files".
- CTAs speak in the first person with the price attached when price is the objection (`Start for $4.99`); never "Learn more" or "Click here". Scarcity must be countable ("this batch has 30 seats"), never "last chance".
- Cut the negative half: "not X, it's Y", "it's about X", "not just X but Y", and a negation dangling at the end almost always read better as the positive claim alone. One credibility word per screen at most (real, genuine, truly, honestly); show a number or a scene instead.
- AI cadence tells to cut: triads on everything ("fast, simple, and powerful"), uniform sentence and paragraph length, synthetic balance, hollow confidence ("powerful" with no number), hedging stacks, throat-clearing openers and closers, em dashes, semicolons. Vary length on purpose; prefer verbs; name names; use numbers. The swap test: replace the product name with a competitor's; if nothing becomes false, the copy is generic.
- Propose, do not apply: only confirmed defects go into the file. A line that passes clean stays untouched even if it sounds flat; taste rewrites go as a before and after table the user picks from, with the text itself shown, never a summary of it. Quotes are never edited. Hunt the echo: after changing a headline, search for its old words (store listing, share card, onboarding, alt text) and update them together.
- Copy that was a decision (a quote, a legal line) is not slop; unverifiable claims are.

## 5. Type

- Use the system font (SF Pro on iOS, `system-ui` on web) unless a real brand font exists. A default nobody chose may be swapped when the Direction's character wants another family: one family for the interface plus at most one partner (a mono for figures, or a display face for large headlines only).
- Use the text styles from `tokens.md` (iOS) or its rem scale (web), not ad-hoc sizes. Hierarchy comes from size and color, not weight.
- Weights: regular, medium, semibold. No w800 to w900, no gradient text.
- Text scaling stays on (iOS Dynamic Type, web `rem` and browser text size). Test the largest accessibility size, or 200 percent zoom on web; layouts reflow instead of clipping. Never pin the size (`TextScaler.noScaling`, `allowFontScaling={false}`, `px` body text).
- No uppercase tracked labels (`NAVIGATION`) except where the system component renders them (grouped list section headers). No italic for emphasis.
- Small text never gets negative letter spacing. Tight tracking is for large display text only.
- Numbers use tabular figures and one format across the screen (`$48,210` next to `$124,860.40` is a bug).
- Hierarchy needs real steps: the dominant heading and the body should differ by at least 1.25x in size (flat hierarchy is a tell), with weight, space and tone doing part of the job. Product UI wants a tighter ratio between steps (about 1.125 to 1.2) and more roles than a marketing screen. Leading at least 1.3x for multi-line text; prose measure 45 to 75 characters on large screens.
- The micro-label tax: a tracked-caps eyebrow above a big headline is the default AI hero; delete it and let the heading speak. Uppercase and wide tracking are for labels of two or three words, never a line of data (caps removes word shape). Tracking at most +0.02em on lowercase, at most +0.16em on short caps; uppercase runs under about 24 characters. Count the distinct sizes on the screen: fifteen is drift, not a ramp.
- Never gray text on a colored surface: derive secondary text from the surface hue or use the foreground at lower emphasis.

## 6. Layout

- Keep sections and their order. Alignment and proportion may change inside a section when that makes it clearer.
- Native structure. iOS: large-title navigation, bottom tab bar (five or fewer), sheets for modal tasks, push for drill-in, inset grouped lists for settings and forms. Web: semantic landmarks, visible current page, real links and buttons, a measure of 65 characters (`platforms/web.md`).
- Long headlines align leading. Centered text is for one or two short lines.
- One primary action per screen, at most one secondary beside it. Everything else moves out.
- Navigation stays quiet: no second button for log in, no decorative pill header.
- Compose the first screen as a whole: no dead empty band; content that is short is centered or lets the main visual run past the bottom edge.
- Every list and data view has designed loading (skeleton with the final shape), empty (says what is missing and what to do) and error (with retry) states. Error is never rendered as empty.
- Tablet and large phones: constrain content width and use adaptive layouts instead of stretching a phone column (`platforms/ios.md`; web: `platforms/web.md`).
- Chrome is a budget. Count the points from the top of the screen to the first item of real content, list each block, and say what you recovered ("460 pt to 64 pt, two more rows above the fold"). Spacing that makes content taller must be paid for by cutting chrome, never content; a change that reduces items per screen with no offsetting cut is a regression.
- Weight is contextual: when the user is choosing from a grid, the deciding datum (a score, a price) is large and scannable; in an already ordered queue it is context, so demote it. The datum that drives the next action gets the most typographic weight.
- Zero is not information: a metric reading zero, or a badge that 100 percent of rows carry, does not render. Absence is an argument: before adding a visual element ask where it will be missing; an element absent exactly on your best records is worse than none.
- Remove filler: a banner, tip or "smart suggestions" strip that fills space and nobody asked for goes (unslop's video removes an "AI smart replies" banner in the spacing pass).
- A control pair (back and forward, minus and plus) is one unit, drawn together beside the label it changes; spread apart on a wide screen it reads as two unrelated buttons. A label becomes an icon only when the option has a shape (grid vs list); an icon that needs a caption is worse than the caption.
- Tables and lists: a variable-width chip before the title misaligns every row; compare-across-rows metadata gets its own fixed-width column; a group total lands in the column of the numbers it sums; define column widths once as constants shared by the row, the header and the skeleton, or they drift silently; the skeleton has the same columns as the content.

## 7. Details

- Nested radius: inner radius = outer radius minus the padding between them, never below 4. Not everything is a pill. Use continuous corners where the platform has them (see the stack file).
- Counts and meta become quiet text, not glowing pills.
- Charts sit on a muted grid with quiet labels. One main chart is clearly the biggest thing on screen; anything else showing data is smaller and different in kind (a ranked list, a short table), never a second chart of the same size.
- One accent per chart: the thing that matters gets it, everything else sits in neutral steps. Several hues only to tell series apart, with one leading.
- Pick the chart for the data: trend is a line, comparison is bars, share is one stacked bar or a list with bars, a goal is a progress bar. A bar past its limit saturates and lies; show the number instead.
- Stat cards are numbers: label, big figure, change with what it compares to. No sparklines, mini bars or icons added to fill them. A real-looking object is allowed only when it is the thing the number counts.
- Vary sizes. Equal cards side by side with the same content read as a template; give the grid a rhythm.
- Active state is a small surface step with a hairline, not a gradient with glow.
- Every tappable element is at least 44 by 44 pt (web: 24 px minimum, 44 on touch-first screens) and has a pressed state in the palette.
- Logo is the product name in the main family plus a simple flat mark. No gradient wordmark, no sparkle tile, no glossy orb.
- The signature detail appears where it belongs and nowhere else.

## 8. Glass

Run only when the app targets a Liquid Glass era of iOS. Rules and fallbacks: `platforms/ios-glass.md`. Skip the pass on web and on every other target (a frosted card is a trend, not a reason); do not add glass to a screen that did not have a reason for it.

## 9. People and visuals

- Decorative filler goes: glossy blobs, orbs, nebulas, floating cubes, glowing grids, holographic brains, robots.
- App screens rarely need generated images. Their moments come from the product: a chart drawn with care, figures set beautifully, real content, a status that feels alive. A physical object the product deals with (a payment card) is usually better built in code with real materials.
- Onboarding, empty states and marketing screens may use a generated scene or object. Details and prompt recipe: `visuals.md`.
- **People and content are moments too.** Initials in colored circles are a placeholder; real portraits (with a small presence dot), real covers and real photos make a list feel alive. Where the product is about people, a collapsible "your circle" row of avatars with names is a strong moment (the video's final step). Never invent people or testimonials: use the user's own assets or label them as illustrative.
- Show the product, not a placeholder: previews use real-looking components with plausible data. Never a labeled gray box.

## 10. Motion

Remove looping motion on things that are not live, bounce curves and overshoot on simple UI, everything flying in from different directions, and animation of layout size on every frame. Everything else: use **unslop-motion**.

## 11. Forms, trust and honesty

- **An empty optional field is not a field.** An optional field with no value becomes a quiet `+ Noun` row; it reopens by itself when it has content (having a value is enough; there is no state to remember). Apply it to all optional fields, not half of them: two modes with no visible criterion are worse than none.
- **Mark the exception, never the rule.** If most fields are optional, mark the required one (asterisk plus a semantic label), do not write "(optional)" eight times.
- **Help text that explains a format becomes the placeholder** (it disappears when it stops being useful); help text that describes what the field already shows goes entirely. A section title that names the obvious goes too.
- **A seeded value never overwrites a human answer**, and seeding never steals focus.
- **A disabled primary button does not explain.** Keep it live (disabled only while submitting) and let the tap reveal what is missing: a message naming the field, focus on it, its border in the destructive color. A disabled primary that is also a double-tap guard needs a synchronous guard.
- **The alert lives where the tap happened:** pin the footer and put the error inside it, next to the button; an error below the fold reads as "nothing happened".
- **Dead controls do not render.** A picker showing "choose the client first" is hidden until its precondition is met.
- **Offer the common choice in one tap** (tomorrow, in 3 days, next week); the raw input stays for the rest.
- **The UI must not lie to the database.** A write that stands for a real-world side effect is guarded by the same condition as the effect, in the handler, not only on the control (a shortcut or menu item bypasses a disabled button). Optimistic UI is fine for display, not for a write that feeds a business metric. A price typed in copy is a claim about the server: read the amount from the same source that charges it.
- **Role says can view; ownership says whose action it is.** Personal controls appear for the owner, not for anyone with a role. A promoted entry must resolve for every role that can see it.
- **Two numbers of different kinds side by side carry labels** (estimate and actual). **Silent-empty is the dominant lie**: a failed fetch painted as zero is indistinguishable from a real zero, and it is usually told one layer down (the service swallows the error). Error and empty are different states; verify by running with the backend off.
- **Destructive actions** never sit next to an innocuous one, never on a reflex gesture, and ship with their undo in the same change; reversibility is what makes fast interaction ethical. Gates (entitlement, quota, permission) live on the server; the app mirrors them.
- **Every entry point passes the same gate:** enumerate the doors (a button, a shortcut, a deep link, a share extension) before enumerating the screens.
