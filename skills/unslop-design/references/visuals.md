# Visuals

Replace decorative filler with a visual that belongs to this product, and generate one only when the screen needs it.

## Decide

1. **Does the screen need one?** Lists, settings, dashboards, forms: almost never. Onboarding, empty states, paywalls and marketing screens usually do.
2. **Is there an image tool?** Look among your tools for an image-generation or design MCP (fal, Replicate, OpenAI images, Higgsfield, Figma). If there is one, show the user the prompt, model and size and ask before running, since it can cost money. Run once, judge against the one-sentence subject, change the prompt instead of rerolling. Save the result in the project's assets, not a temporary URL.
3. **No tool?** Say so before the pass and offer to connect one. If the user skips it, leave an empty slot of the right size: a plain surface step with the layout's radius and no text inside, so nothing unfinished ships. Put the prompt in the report, never on the screen.
4. **Show the product.** Build a preview in code of what the screen already promises: the one moment that proves the headline (one week with a booked slot, one diff with a comment, one streak on one card), with plausible data.
5. **Write the subject as one sentence** from the Direction's world. If it cannot be said in one sentence, it is not clear yet. Shape only: a backup tool is a small lighthouse on a dark coast with its beam in fog; a meditation app is one cup of tea steaming on a windowsill at first light. Derive yours from the product.

Avoid the AI defaults unless the product is about them: glossy blobs, orbs, nebulas, chrome liquid, floating cubes, neon circuits, holograms, glowing brains, robots, rockets, crystals.

## Styles that work (pick one, keep it for the whole flow)

- Painted background art: a calm sky or landscape with one subject and open space for text. Warm, hopeful, human products.
- Cinematic photo of one object: a single real thing in simple dramatic light on a plain field. Calm, serious, trustworthy products.
- Soft stylized 3D: one small scene with matte materials and gentle light. Playful or friendly products.
- Product object render: a real-looking object from the product (payment card, phone, parcel), studio lit, used as a moment inside the interface.
- Light and optics: one physical phenomenon on a dark field. Technical or data products.
- Engraving or print: monochrome in one ink on a soft tinted page, with type and palette from the same world. Only when the whole brand lives in it; on one image of a plain interface it reads as a filter.

What fails: prompts asking for film or paper grain (models bake in a checker pattern; add texture in code), several subjects or collages, purple-blue glossy abstractions.

## The visual is made of the product's own material

The strongest unslop references make the image out of what the product handles: an invoicing hero where a paper plane is drawn in digits and currency signs with small notes pinned to it (the visual is the moment and the signature at once, and the text sits on calm space); a monitoring product drawn as one blue engraving of a lighthouse with the serif headline in the same ink (a print style works only when the whole screen lives in it: one ink, one paper tone, matching type); a quiet-reading product as a soft 3D meadow with matte crystals and a huge wordmark standing behind the hills. Take qualities (one bright element, quiet chrome, a subject sayable in one sentence, text on space left empty for it), never subjects or layouts. For iOS this applies to onboarding, paywalls and empty states, not to working screens.

Code treatments that make an image native: render it as glyphs drawn from the product's own characters (money: `. : 1 7 4 0 8 $ %`; code: `. : / { } < > =`), halftone dots, a dither into two ramp colors, or a duotone (`ColorFiltered`). Sample once when the image loads, never inside the paint loop; animate at 8 to 12 steps per second at most; pause off screen; cap pixel ratio at 2. Use one on the main visual only, and only when it fits the Direction.

## Accent from artwork

When a screen should tint itself from an image: downscale to about 40 px; weight each pixel by `saturation * 0.7 + brightness * 0.3` (not frequency, which returns the background); skip near-white and near-black outliers; darken a near-white winner (about 0.75); pick text by perceptual luminance (`0.299 r + 0.587 g + 0.114 b > 0.55` means dark text). A duplicated, heavily blurred copy of the artwork behind a hero card reads as a halo tinted by the content, better than a black drop shadow; reserve it for the one hero card.

## Objects for moments

- Ask for one object, studio lit, on a plain background in the exact page color, soft contact shadow, nothing else in frame, at the angle the layout needs.
- Cut the background out if the tool can; otherwise blend with a mask. Background removal eats dark areas near the background color (a switched-off black screen), so ask for the screen in a contrasting flat color.
- Place it overlapping a card edge, slightly rotated, with a soft shadow in the ramp's darkest color.
- To show real UI on a generated device, generate it straight-on, measure the screen rectangle, lay widgets over it and rotate both together. Text stays sharp.
- Everything inside one visual tells the same story: if the list shows invoice INV-0142, the phone shows the same client, number and amount.

## Prompt recipe (in this order)

1. Subject (the one sentence, concrete and physical)
2. Setting (simple)
3. Light and palette (name the page background color so edges can blend; direction of light)
4. Style (one direction)
5. Composition ("subject on the right, calm empty space on the left"; keep the lower fifth calm if the UI rises over it)
6. Exclusions (no text, letters, logos, UI, watermark)
7. Format (aspect ratio of the slot at 2x or 3x display size)

## On screen (Flutter names; React Native and web: the same rules with `expo-image` / `<img width height srcset>`)

- Export WebP at 2x to 3x display size; give it a real semantic label saying what is shown.
- Fixed dimensions and `precacheImage` so the layout does not jump.
- Match the image's edges to the page color; if they differ, fade them with a gradient overlay in the page color or a `ShaderMask`. A hard rectangle on a page of a different color is slop.
- Static, or one slow subtle motion that fits the subject. No parallax.
- Code treatments (glyph, halftone, dither or duotone drawn in a `CustomPainter` or with `ColorFiltered`) can make an image feel native. Use one only when it fits the Direction, on the main visual only, sampled once when the image loads and never inside the paint loop.
