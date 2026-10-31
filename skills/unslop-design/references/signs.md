# Signs of slop

Go through every group, note each sign with where it lives. Format: sign -> fix. Signs are stack-neutral; code names in parentheses are examples (Flutter `BoxShadow`, CSS `box-shadow`, React Native `shadow*`). Web-specific tells are in `platforms/web.md`. Grep helpers for most of these live in `unslop-review/scripts/slop-grep.sh`.

## Surfaces and color
- Purple-to-blue or violet-to-pink gradients on backgrounds, cards, buttons, active tab -> one neutral surface, accent only where it means something
- Gradient text in headings, numbers, logo -> solid text color
- Colored glows (`BoxShadow` / `box-shadow` / `shadow*` with a saturated color, blur 20+) -> remove; depth from surface steps and hairlines
- Radial color washes or blurred blobs behind content -> remove
- Neon or high-contrast colored borders -> hairline separator
- Five near-identical tints of one hue for text -> three text roles
- Every element highlighted, so nothing stands out -> one accent, once or twice per screen
- Hard-coded `Colors.white` / `Color(0xFF...)` that breaks in dark mode -> semantic dynamic colors
- Rainbow card: every figure in a breakdown has its own color -> one neutral; color only for a real exception (over limit, overdue); outflow marked by a typographic minus
- Opacity ladder: `withOpacity` 0.9 / 0.7 / 0.5 / 0.4 in one block -> two or three tones from the ramp
- Saturated progress bar (full and red beside "274% used") -> show the number past the limit

## Type
- Weight 800/900 headings -> regular or medium; size carries hierarchy
- Uppercase labels with wide tracking -> sentence case, normal tracking (except system-rendered section headers)
- Too many sizes and weights on one screen -> the iOS text styles
- Mixed number formats (`$48,210` beside `$124,860.40`, `07`) -> one format, tabular figures
- Negative letter spacing on small text -> zero or slightly positive
- Italic used for emphasis, or one italic serif word in a headline -> color or weight, or nothing
- Display serif with tight negative tracking as the "look" -> the product's real font, tracking measured on screen
- Mono font on eyebrows, buttons, dates, captions, money -> mono only for IDs, hashes, code; tabular figures for numbers
- `textScaler: TextScaler.noScaling` or fixed-height text boxes -> let it scale, let layouts reflow

## Icons
- Emoji as nav icons, label decoration or status (🏠 📥 🚀 💰 ⚠️ 🔥) -> one icon set or nothing
- Emoji inside pills and counts (`18 👤`) -> plain number
- Arrow glyphs in text (`→`) -> a real icon
- Icons in many sizes, colors or weights -> one size, one weight, text role color
- Icons nudged off the column -> same icon box width in every row
- Sparkle ✨ for anything AI -> remove, or a plain icon only where it explains something
- Hand-drawn SVG icons where a set icon exists -> the set

## Spacing
- Arbitrary values (`EdgeInsets.only(top: 13)`, `SizedBox(height: 7)`) -> scale steps
- Rows in one list with different heights or gaps -> one height, one gap
- Groups closer to their neighbours than to their own items -> tight inside, open between
- Same gap on every level (`SizedBox(height: 16)` everywhere) -> each level at least 2x the one inside
- Uneven padding inside sibling cards -> one padding
- Big gap above a section, cramped below -> balanced rhythm
- Hard-coded top padding for the status bar -> `SafeArea`

## Copy
- Greeting headlines (`Welcome back, Sam! 👋`) -> the page or period as title
- Exclamation marks, `!!`, alarm punctuation (`Warning!`) -> plain statement of fact and consequence
- Changes without a reference (`+12%!!`) -> `+12% vs last month`
- Wordy placeholders (`Search anything...`) -> `Search`
- Hype words (supercharge, seamless, unlock, magic) -> what the thing does
- Trailing periods on labels and buttons -> none
- Fake data (`$123,456`, `[X]`, `John Doe`) -> plausible numbers and names
- "Click to...", "Tap here to...", "Swipe to...", captions describing what sits two inches away -> delete; people find out by using it
- Same information in title, subtitle and first card -> say it once
- Error shown as "Something went wrong" -> what happened and what to do

## Components
- Banner, strip or card that exists only to fill space (`AI smart replies`, `Tips for you`) -> remove it (filler)
- Emoji compose or add button (a pencil emoji in a blue circle) -> a plain line icon in the system tint, or a glass control
- Red numeric badges on every row -> one small tint dot for unread; counts only where the number decides
- Outlined blue chips -> quiet neutral chips with one selected state
- Initials-in-colored-circle avatars where people are the product -> real portraits with a presence dot
- Nested cards (a card inside a card) -> flatten: spacing, type and dividers do the grouping
- Identical cards of icon plus heading plus text as the screen structure -> fewer items, varied sizes, or a list
- A small rounded-square icon tile above every heading -> the heading alone, or a bare icon
- Ghost card: hairline border plus a wide soft shadow on every card -> declare elevation once (border or shadow)
- Over-round: radius 24 and up on cards, everything a pill -> card radius 16 to 20, pills only for small controls
- Colored border on one side of a card or alert (side stripe thicker than 1 pt) -> a full hairline or a tinted icon
- Hero-metric template as a screen scaffold (big number, small label, supporting stats, accent) -> a real composition; on an Operate screen a stat row is fine when the figures decide something
- Pulsing status dot on something that is not live -> static, or tie the pulse to a genuinely live state
- Marquee or auto-scrolling strip -> static content
- Gray text on a colored surface -> a darker tint of that surface, or the foreground at lower emphasis
- The same text repeated three or more times inside one card -> say it once
- Glowing pills for counts, plans, status -> quiet text
- `PRO`, `New ✨`, `Beta 🚀` badges, or a chip on every card -> remove; a tag only when it filters or changes a decision
- Everything a full pill (search, buttons, cards) -> radius by size, nested radius math
- A bordered box around every group; box inside a box -> one level of container; group by space
- A divider between everything -> space groups; lines only in tables and dense lists
- Rainbow, glowing, pill-shaped or uppercase-labelled chart bars -> one or two series, muted grid, one highlight
- Sparklines, tallies, mini bars on every stat card -> number, label, change
- Equal cards side by side each with the same chart -> one main chart, compact stats, varied widths
- Logo as gradient tile with sparkle, or glossy orb -> product name as text plus a flat mark
- Over-detailed preview with forty tiny elements -> the one thing the product does, at a size that reads
- Dot-grid or noise texture behind everything -> flat surface
- Synthetic cover: gradient chosen by hashing the name, giant initial -> real image, or one neutral icon of the item's type
- Dropdown/picker for 2 to 5 options -> segmented control
- Numbers with no unit in a settings or tool panel -> unit after the value, dimmer

## Material on iOS (Flutter names; on React Native the same slop is `android_ripple`, `TouchableOpacity` everywhere and hand-built headers)
- Material `AppBar`, `Drawer`, `FloatingActionButton`, `BottomNavigationBar` -> large-title navigation bar, tab bar, a toolbar or in-content primary button
- Ink ripples on iOS -> pressed-state opacity or scale
- `Card` with default elevation shadow, `ListTile` dividers everywhere -> grouped list sections
- Material `SnackBar` for confirmations -> inline state change, or a quiet toast
- `Scaffold` with Material page transitions -> `CupertinoPageRoute` with swipe-back
- Android scroll glow/clamping on iOS -> bouncing physics
- Hand-rolled switches, sliders, pickers, context menus -> the Cupertino versions

## Data and states
- Spinner centered in an empty box -> skeleton with the final shape; static structure paints, only data waits
- Skeleton or spinner that never leaves (`catch` clears data but not loading) -> every catch ends in a state the screen can paint
- Failed fetch rendered as "0 items" -> error state with retry; error and empty are different
- `0.0%` from a zero denominator -> no ratio, no line
- A card full of `$0.00` -> one-line empty state saying what is missing
- Hypothetical figure shown with the same authority as real data -> label it or hide it
- Same value shown twice in one card -> once, where it decides something
- Layout that jumps when images or data arrive -> reserve the box (aspect ratio, final skeleton)
- Network image without an error builder -> fallback tile

## Landing, onboarding and hero screens
- Pill badge above the headline (`✨ Introducing X 2.0`) -> remove
- A headline that fits any product (`Supercharge your workflow`) -> what the product does, for whom
- Everything stacked and centered: headline, text, buttons, picture below -> asymmetric layout, or text over a large product view
- Three or more buttons or chips stacked under the headline -> one primary, at most one secondary
- `Trusted by 10,000+ teams`, avatar dots, five stars without a source -> ask if real, then specific or remove
- Floating blobs, orbs, grids, glowing lines behind the hero -> plain surface or one real product visual
- Scroll hint ("Scroll", mouse icon, bouncing arrow) in the hero -> delete; fix composition instead
- Feature cards with an emoji, a bold title and a vague line -> fewer features, concrete copy
- Stock robots, glowing brains, circuit lines for anything AI -> show what the AI actually produces
- Text or fake buttons baked into an image -> real text over a clean image
- Image whose edges do not blend into the page -> match the background or fade the edge
- A visual in every section -> one visual where it helps

## Motion
- Repeating animation on things that are not live (pulse, ping, breathing glow, floating) -> static
- Bounce or elastic curves and overshoot on simple UI -> one ease-out curve
- Everything entering from different directions -> one short fade and rise with a small stagger
- Staircase list: index-based delay on a long list -> list appears whole
- Everything animating at once (queue, images, progress bar, toast) -> one focus of motion at a time
- A 200 degree spin, 20 particles, big overshoot ("amplitude mistaken for quality") -> cut the amplitude in half, then half again
- Parallax and scroll-driven drift on app screens -> static
- Animating width, height, top, left each frame -> transform and opacity

## Glass
- Glass on content cards, rows or full-screen backgrounds -> glass only on floating controls
- Glass stacked on glass -> one layer or group
- Glass over a flat solid background (invisible effect, real cost) -> solid surface, or put real content behind it
- Live glass on an element being dragged or animated fast -> static translucent fill during motion
- Frosted panel with opaque fill (blur has nothing to blur) -> delete the blur

## Reflex palettes and type (Impeccable's calibration)
- Cream or beige page with a thin serif display and an italic accent word, reached by reflex ("tasteful") -> a ground chosen from the use scene (who, where, under what light)
- Near-black with one neon accent and glowing edges -> committed color that does real jobs
- Flat saturated ink with hard black offset shadows (neo-brutalism) outside a world that chose it -> soft offset-and-blur depth
- Training-data fonts reached for as "the look" (Inter-as-display, Space Grotesk, Plus Jakarta Sans, DM Sans, Outfit, Fraunces, Playfair, Instrument Serif/Sans, Geist) -> the system font on iOS; a brand face only with a reason no other face could satisfy (a subject association such as "books want a serif" is not a reason)
- Flat hierarchy: heading and body less than 1.25x apart -> real steps
- Light or dark chosen by category -> chosen by the physical use scene

## Template look (what a cleaned-up screen falls back to when nobody decides)
- Pure grey page, system font, white text, the old brand color on one button, on a product whose world is warm or bright -> accent and chart colors from the world
- A headline that fits another product if you swap the name -> the product's own nouns
- A hero that is an empty box or generic picture -> a product preview in code or an image from the world
- Every product getting the same layout, type and palette -> let the Direction choose
- The one-italic-serif-word headline, the dot grid, the numbered section labels (`01 - Services`), the code-breadcrumb decoration (`~/projects/app`) -> they imitate care; delete
