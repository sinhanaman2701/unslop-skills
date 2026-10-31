# Web verification

Headless Chrome from the command line (`--window-size`) enforces a minimum window width of about 500 px, so a 390 px capture is a crop of a wider layout and shows false overflow. Use `puppeteer-core` (`npm i puppeteer-core`, pass the installed Chrome as `executablePath`) with `page.setViewport`, and read `document.documentElement.scrollWidth` against `clientWidth` to prove there is no horizontal overflow.

```bash
# a local server for static pages (no install): python3 -m http.server 8123
# Headless Chrome screenshot at a width and device pixel ratio:
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu \
  --window-size=390,1400 --force-device-scale-factor=2 --hide-scrollbars \
  --screenshot=shot-390.png http://localhost:8123/
# dark scheme and reduced motion for a capture:
#   add --force-dark-mode, or emulate in a Playwright/Puppeteer script (below)
```

For states the CLI cannot set (dark scheme, reduced motion, forced colors, CPU throttle, keyboard), script a browser. With Playwright (`npm i -D playwright`, `npx playwright install chromium`):

```js
const { chromium } = await import('playwright');
const b = await chromium.launch(); 
for (const [w, scheme, motion] of [[390,'light','no-preference'],[390,'dark','no-preference'],[1440,'light','no-preference'],[390,'light','reduce']]) {
  const ctx = await b.newContext({ viewport: { width: w, height: 900 }, colorScheme: scheme, reducedMotion: motion, deviceScaleFactor: 2 });
  const p = await ctx.newPage(); await p.goto('http://localhost:8123/'); await p.waitForTimeout(1200);
  await p.screenshot({ path: `shot-${w}-${scheme}-${motion}.png`, fullPage: true });
}
await b.close();
```

- **Mechanical gate:** axe (`npx @axe-core/cli http://localhost:8123/`) or Lighthouse (`npx lighthouse ... --only-categories=accessibility,performance`) finds roughly a third of accessibility defects; the keyboard pass finds most of the rest.
- **Keyboard pass:** Tab through the whole flow; visible focus on every stop; Enter and Space activate; Escape closes dialogs; focus returns to the trigger.
- **Zoom:** 200 percent text and a 640 px viewport; no horizontal scroll, nothing hidden.
- **Layout shift and speed:** DevTools Performance with CPU 4x throttled and Slow 4G; Core Web Vitals (LCP under 2.5 s, INP under 200 ms, CLS under 0.1).
- **Motion feel:** DevTools Animations panel at 10 percent, or temporarily multiply the duration tokens by 4.
- **Scanner:** `bash ~/.claude/skills/unslop-review/scripts/slop-grep.sh --stack web src` (add the directory that holds your HTML, CSS and components).

Deterministic slow-motion: pause every CSS animation and scrub it to a time, then screenshot:

```js
await page.evaluate((t) => document.getAnimations().forEach((a) => { a.pause(); a.currentTime = t; }), 400);
```

Strong ease-out curves are front-loaded (a 700 ms draw is about 90 percent done by 40 percent of its time), so scrub at several times (0, 150, 400, 700 ms) to see the whole motion. Keyboard test in the same script: `page.keyboard.press('Tab')` per stop, record `document.activeElement`, then arrow keys inside a radio group and read the resulting state.
