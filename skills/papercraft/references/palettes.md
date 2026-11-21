# Palettes for paper

How to choose and derive colour for paper work: roles, the rules that keep it reading as printed card, and eleven
starting palettes in `assets/palettes.json`.

Read this when: choosing colours for a new piece, restyling a template for a new subject, or when a frame looks
garish, muddy, "video-game" or flat.

## 1. Roles, not swatches

A paper palette is a set of roles. Fill every role before you pick any other colour:

| Role | What it is | Rules |
|---|---|---|
| page | bare paper stock (paths, light patches) | cream; never pure white |
| ground light / dark | the printed ground, two tones | muted (olive-khaki by default) and paler and greyer than the cards (rule 9), so the pieces carry the colour; 15-25 % apart in value |
| subject (3-6) | the colours of the main pieces | a warm lead family (orange, rust, ochre by default) from the subject's own materials |
| accents | 1-2 per piece, plus one small warm note of light and life | contrast with the piece's base, never tone-on-tone (`accentsFor(base)`); the warm note under ~5 % of the frame |
| ink | linework, outlines, printed marks | the darkest subject hue pushed toward umber; never `#000` |
| edge | dark cut line + lit-side highlight | not a palette colour: `P.rim()` derives it from each print, in every mood |
| leak | the colour shadows let through | warm amber `#a0602c` by day, deep navy at night, mood-tinted otherwise (`look.md`) |
| haze | distance colour, applied in display space | a mid tone, never near white; subtle, far only |
| key / fill | light colours | mild (key `#ffdcb2`, frontal fill `#f2dcc2`): warmth goes in the grade, not in a 3000 K key |

## 2. Rules that keep it paper

1. **One lead family on a muted ground, both from the brief.** The subject chooses the hues (a reef: coral and
   kelp on pale sand; a station: teal panels and amber lights on pale deck plates; autumn countryside: orange, rust
   and ochre on olive-khaki); the style fixes only the structure: one family the pieces carry, on a ground paler and
   less saturated than they are. The shipped game's biomes each kept one family; five competing hues read
   as a toy box.
2. **Every surface has two tones, marks and contrasting accents.** Base, a shade (mix 25-35 % toward warm umber
   `#2b1a0e`), a light (mix 15-20 % toward cream `#fff7e8`), speckle, and 1-2 accents that contrast with the base
   (red + olive leaves on an orange tree, cream flowers and red berries on a green bush; `accentsFor(base)` gives a
   fallback pair), never tone-on-tone. `shade()` in `assets/lib/paperkit-2d.js` darkens toward umber, never grey.
3. **Rich, not neon.** Mean HSV saturation of the final frame ~0.55-0.75 (the shipped reference frames measure
   0.58-0.73); print colour can be rich if the grade pulls it back a little (~0.96). No colour fog or sepia filter
   over the frame; haze, if any, subtle and only in the far distance.
4. **No pure white, no pure black.** Cream and warm ink. The darkest 20 % of pixels should be warm umber (navy at
   night).
5. **Greens are sage.** Yellow-green under a warm key reads as video-game grass. Start greens desaturated and warm
   (`#a8a374`, `#8c9765`) and keep a hue-masked desaturation in the grade (`look.md` section 7).
6. **Layer value steps.** Stacked layers step 10-15 % darker going away from the light; far layers drift toward the
   haze colour.
7. **Readable pieces.** A pale piece on a pale ground disappears: mount it on a darker backing sheet cut ~8 % larger,
   or give it a pale glue tab on a dark ground. Dark pieces (pines, iron, night) need a value floor (luma >= ~40/255)
   and dark kraft side faces, never a white edge.
8. **Keep constants across moods.** If one project has several moods (day/night, biomes), keep two things fixed so it
   stays one world: the wood/structure colour and the warm window/lamp colour (cut edges follow each print).
9. **Author grounds paler than you want them on screen.** In the frame the ground sits ~0.16-0.22 brighter and
   ~0.16-0.25 less saturated than the cards standing on it (`look.md` section 1). The warm key, ACES and the tint push
   albedo warmer and more saturated (a test agent's `#dcc196` sand rendered `#C88C42`), so author it further apart
   still: the starting palettes put the ground's light tone ~0.2-0.3 above the cards' mean luma (snow more) and
   ~0.15-0.45 below their mean saturation. Check it with `measure.py --palette` on the test card.
10. **Foliage outside autumn.** In non-autumn biomes carry the contrast with flowers and fruit (red, cream, gold), not
    red leaves on green, which reads as Christmas or autumn. Choose the accents for your prints yourself
    (`accentsFor` is only a fallback rule; the countryside examples take `colors.accents`).

## 3. Deriving a palette for any subject

Derive it; never reuse one. The example scenes' palettes and the starting palettes below are calibration (how roles,
ratios and contrast work), not colours to copy: blind tests that started from the example reproduced its roofs,
greens and river in a space station and a lantern festival.

1. Name the subject's materials (a Mars dome: rust dust, oxidised steel, glass panes, greenhouse plants; a reef:
   coral, kelp, sand, deep water; a city: brick, slate, signal lights). Paper versions of those materials are the
   subject colours: pick the matte, slightly faded version of each.
2. Pick the ground, muted and authored pale (rule 9): the colour the world is printed on (olive-khaki by default; sand
   for deserts, pale stone for cities, sea-foam for water, a pale kraft tone for rustic; at night the day ground
   re-lit, section 5).
3. Give every piece contrasting accents (`accentsFor(base)` is a starting pair) and choose ONE small warm note of
   life or light (lamps, windows, a creature, a flag).
4. Make the ink from the darkest subject hue pushed toward umber; it stays the same at night (section 5).
5. Light: a key slightly warmer than the ground, a frontal fill tinted with the mood's warm or cool complement, the
   leak a warm amber by day (a darkened mood colour otherwise), the haze a subtle mid-tone of the far scenery.
6. Check against the rules above (the ground against the cards first: rule 9), render the test card, and run
   `scripts/measure.py` for saturation, darkest-20 % colour and palette spread.

## 4. Starting palettes

All eleven are in `assets/palettes.json` (load it, or copy values). They are calibrated starting points, not a
menu: twist them toward the subject. The key, fill, leak and haze of storybook-autumn, golden-hour, dusk-violet and
lantern-night are the 3D template's measured day, golden, dusk and night sets (`look.md` section 8); dusk-violet and
lantern-night keep storybook-autumn's colours and change only the light, which is how any palette goes to dusk or
night.

| Name | Mood | Ground (light) | Subject | Accent | Ink |
|---|---|---|---|---|---|
| storybook-autumn | golden countryside (the worked example's) | `#cbc79f` | ochre, terracotta, sage, pine, red-brown wood | `#c8452d` | `#5a3a28` |
| golden-hour | low warm key, long shadows; pale sand / ochre ground the key warms | `#d8caa6` | orange, rust, gold, brown, sage | `#c8452d` | `#3a2412` |
| desert-noon | white-hot sun, rose shadows; pale sand | `#d3b994` | burnt sienna, cactus olive, cloth red, dusk blue | `#4fa3a0` | `#5a3426` |
| snow-cabin | cold blue fill, warm windows | `#e8edf2` | blue-white snow, dark pine, timber | `#ffc45a` | `#3d3447` |
| blossom-spring | peach key, lilac fill | `#dce1bb` | pink blossom, soft green, bark | `#f3b04a` | `#5a3a3a` |
| misty-forest | soft far haze, teal fill; a pale sage floor | `#a7bb9b` | moss, dark pine, mushroom red | `#f2d27a` | `#2f3a33` |
| jungle | deep and sage greens on pale warm olive; flowers and fruit carry the contrast (rule 10) | `#d5cba6` | deep green, sage, bark, gold fruit, cream flowers; river teal | `#c8452d` | `#332f1c` |
| dusk-violet | storybook-autumn re-lit at dusk: low warm key, violet fill, lit windows | `#cbc79f` | as storybook-autumn | `#ffc45a` | `#5a3a28` |
| lantern-night | storybook-autumn re-lit at night: a dim pale-blue moon, warm lamp pools | `#cbc79f` | as storybook-autumn | `#ffc45a` | `#5a3a28` |
| sea-teal | aquatic, cool and clear: a pale sea-foam floor, the deep teal as water | `#c2e9d6` | sand, coral, apricot, kelp; deep teal water | `#f6e7d0` | `#213a44` |
| industrial-tin | machines, towns, cities: pale stone underfoot | `#d0bfa2` | slate, steel blue, copper, brass, signal red | `#ffc45a` | `#2a2a30` |

A rustic or a nursery brief twists one of these (a pale kraft-toned ground, softer accents) rather than switching to a
two-ink or pastel print: every piece still carries 3-5 inks and the frame still lands at S ~0.55-0.75.

## 5. Night and coloured light

At dusk, at night and in every other mood the palette is re-lit, not repainted: keep the day albedo and swap the light
rows (key, fill, leak, haze), as dusk-violet and lantern-night do over storybook-autumn (the 3D template's
`?mood=dusk|night`). How the night set looks and what to check (warm windows and lamps, navy only far away and in the
deep shadows, warm prints that go black) is in `look.md` section 8. The cut edges still come from each print
(`P.rim()`). If a piece must change colour at night (a lamp pane), use a dim amber paper for "off", never near-black.
