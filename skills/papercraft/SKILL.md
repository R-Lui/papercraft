---
name: papercraft
description: >-
  Builds games, interactive scenes, web pages, animations and videos in a handcrafted pop-up book papercraft style,
  for any subject (a Mars base, a reef city, a village): printed cardstock pieces with thin cut edges that fold up on
  hinges from a printed ground, warm soft layered shadows, a tilt-shift macro lens, calm hinge motion and soft paper
  sounds, built in the browser with three.js or Canvas/SVG/CSS and no image generation needed. Use when something
  should look, move or sound like paper or card (pop-up, papercraft, paper diorama, cut-out, made of paper,
  handmade, storybook). Not for real folding instructions, printable craft patterns, or paper as in documents.
license: MIT
compatibility: Templates and kit run in any modern browser (three.js r187 via CDN). Scripts need Python 3 with numpy and Pillow. Image generation is optional.
metadata:
  author: xikhar
  version: "0.3.0"
---

# Papercraft

One style, any subject: a pop-up diorama seen from inside. Illustrated cards, printed with ink on fibrous cardstock
and cut out, stand up from a printed ground on hinges; they rise with a springy overshoot and settle, cast warm soft
shadows on the ground and on each other, and are seen through a long macro lens looking down into the world, with a
shallow tilt-shift focus band, as if a real paper model were photographed. Everything here comes from a shipped
browser game in this style and was paid for in critic rounds and user feedback; the numbers are starting points that
held up, not decoration. The brief always wins over these defaults.

This skill teaches a method: what makes the style read, how to construct and print any piece, how to light, frame,
move and check it. You write your subject's pieces yourself. The code in `assets/` is plumbing you may import (paper,
cards, the layered print, hinges, light, lens, the walk field) plus worked examples from one countryside world to read,
never a catalogue of parts to assemble a new subject from.

## 1. The material model (what makes it read as paper)

Get these right on every run; each line says why. Details and more numbers live in `references/look.md`.

1. **Everything is a flat sheet with thickness.** Form comes only from cutting, folding, layering and slotting, never
   from sculpted volume. Card thickness 1.5-3 % of the hero's height. A zero-thickness plane reads as a sticker, a
   thick one as foam board.
2. **Dead matte.** Diffuse light only, soft terminator (wrap ~0.3), no specular, no reflections, no gloss. Clipped
   pixels under ~1 % (only small lit panes may clip). Any sheen at grazing angles reads as plastic or wet.
3. **One warm low key, soft coloured shadows.** Key from the side, 45-65 degrees off the camera axis, 45-55 degrees
   up (20-35 only at golden hour and dusk) and a little toward the camera, so shadows fall sideways and behind, where
   the camera sees them (a key from behind the camera hides every shadow). A frontal fill at ~1/4-1/3 of the key keeps
   camera-facing cards from going grey. Shadows are crisp where a card meets the ground and widen with the gap
   (penumbra ~0.2-0.3 x gap). Their hue comes from the world: a warm amber on warm ground by day, lilac-blue on snow,
   a deep teal under water, navy at night; the pieces themselves stay warm in every one. Never grey or black shadows,
   never a coloured fog or filter over the frame. Every standing piece visibly touches the ground (contact
   darkening); check the shadows with the key alone (`look.md` section 8b).
4. **Every print is a small layered paper collage.** Inside each chunky silhouette: 3-5 inks in 3+ value steps plus
   one ornament, laid as cut layers back to front on a base sheet with one quiet fibre (never plush felt or a weave):
   structure first (limbs, tiers, shingle rows, frames, panels, a band), then bold motifs that CONTRAST with the base
   (leaves and petals, rivets and panel lines, scales, scallops, stripes, windows). Every layer drops a short soft
   warm shadow on what lies under it and shows a thin pale lip on its lit edges; big layers also an even pale cut
   edge. That pair is what reads as layered paper instead of a vector fill. Nothing bare, thin or spiky: no line
   under ~2-3 % of the piece, motifs big and countable (the countryside example's tree crowns carry 15-25 leaves, each
   ~1/7 of the crown's width). Printed illustration was the biggest quality jump in the source project (6 of 6 blind
   wins over plain cards). Kit: `P.layer`, `P.parts`, `drawnPiece`, `P.marks`, `P.rim`.
5. **The cut edge.** A thin dark-brown line right at the silhouette (the card's thickness and printed outline, ~1.5-2.5
   px on screen), and a pale highlight just inside it only on the edges that face the light. Never an even pale or
   white band all round (a sticker halo), never glowing, never torn. A fold is not a cut: hinge bases and panel joins
   get no edge. No card is ever seen edge-on as a knife-thin sliver.
6. **A macro lens looking down into the world.** Long lens (24-32 degree vertical FOV), camera 40-55 degrees down, and
   the printed ground runs past every edge of the frame: no horizon, sky, backdrop, book edge or table in view (unless
   the brief is literally a book or a page inside a UI). One sharp band covering ~36-45 % of the frame height on the
   hero's scene (measured: `measure.py` focusHeight >= 0.35), blur growing above and below to 12-18 px radius at
   1080p (3D template 18; 2D template 9 as a Canvas `blur()` sigma), driven by depth as well as screen height. Big
   blurred pieces overlapping the bottom edge sell the miniature scale.
7. **The brief's own palette, built the paper way.** Derive the colours from your subject, mood and time of day
   (`palettes.md` section 3): never the example scene's or a starting palette's hexes as they are (blind tests copied
   the example's roofs and greens into a space station). What stays: one lead family the pieces carry, on a pale,
   muted ground (~0.16-0.22 brighter and ~0.16-0.25 less saturated than the cards), so the pieces carry the
   colour; every piece has one or two accents that contrast with its base (cream rivets on a rust dome, red leaves on
   an orange tree), never tone-on-tone. Sage instead of video-game green, cream instead of white, warm ink instead of
   black. Frame mean saturation (HSV S) ~0.55-0.75. The grade warms written colours (an olive-khaki ground turns
   mustard, a grey teal sage): author grounds and water a step bluer and greyer and check the frame
   (`measure.py --palette`).
8. **Dense, chunky, readable.** A full model world, not props on a plain: 100-250 pieces of ~20 kinds (standing cards
   whose base is in frame) in tight groups of 4-8 DIFFERENT pieces (the countryside example: a tree, bush cards, a
   rock, flowers, an animal; a reef: a coral head, sponges, kelp, a fish; a station: crates, a pipe run, a lamp, a
   robot), at most ~3 identical props in view, the sharp band packed (`measure.py` barePct <= ~55) and the open ground
   mostly outside it (paths, water, a few clearings). The ground stays flat: height comes from nested parallel cards
   (3-5 curved sails stepped ~10-15 % in value: hills, dunes, banks, drifts) and outcrops, never a raised block of
   terrain (`mechanisms.md` section 8). The hero is the scale figure (3.6 units in 3D, ~3.2 in 2D; a place-only brief
   keeps a few figures), 6-10 % of the frame height: a small 3D paper MODEL (~10-20 cards) that reads from every side
   and turns to face the way it walks (a frontal card with a profile card behind it for each part; legs and arms on
   pivots that swing with the distance walked; a forward lean and a roll into turns), never one flat card, with a
   readable face, costume detail, chunky toy-like proportions and colours that contrast with the ground, standing in
   the sharp band (`mechanisms.md` section 12, `motion.md` section 8; the example scene's `heroDoll` is one model). Pieces are chunky against him (sizes and layout: `worlds.md` sections 8-9); a hero that
   is itself a landmark may take 25-35 % of the frame; tall landmarks are layered flats cut by the top edge.
9. **What is walked on, under or into is BUILT in 3D, never a standing flat.** A standing card is only for things
   seen from the front and walked around (trees, bushes, props, critters, far backdrop hills). Walkable height is an
   OPEN construction: a bridge is deck ramps with a crown panel (planks across) between outward-leaning parapet sides
   with an arch cut; a jetty, pier or lookout is a plank deck on posts (`platform()` with a posts face, the gaps cut
   to the base); stairs are thin plank treads on two stepped stringers (rise <= ~1/8 of the hero's height); a walkway
   is a plank deck between two side cards. A solid box with a printed face (`terrace()`) only for built masonry the
   brief names (a quay wall, a stage), never for natural terrain. Anything entered is a box fold with an opening;
   water, paths and fields are printed into the page. The walk logic reads the same construction: feet on the deck;
   parapets, walls and water stop the hero (`WalkField`, `mechanisms.md` section 14).
10. **Paper moves by rotating about creases.** Rise fast with 8-15 % overshoot and a 2-3 cycle quiver, still by ~1 s;
   fall softer with one small slap on the ground; stagger parts 0.05-0.1 s; nothing scales, stretches or fades in.
   Continuous motion (idle sway, walk bob) stays subtle: users cut critic-requested bob by 2-3x.
11. **Sound, if any, is soft, low, dull and sparse.** Noise-based flaps, one per gesture, at least ~0.5 s apart.

## 2. Before code: write the paper spec

Write this block into your plan (or a comment at the top of the main file) and fill every line with numbers. Then
audit it: "would I write this exact spec for any similar prompt?" If yes, push the palette, printed motifs and
silhouettes toward the subject's own world (a Mars dome gets rust and oxide cards with printed rivets and panel
lines; a reef gets coral, kelp and teal water cards with scalloped edges; never the countryside defaults of the
templates). What changes with the subject: silhouettes and printed motifs, palette and mood light, which mechanisms
build the forms, what the hero walks on, the layout and the world's own sounds under the paper flaps. What never
changes: laws 1-11.

```text
SUBJECT    the world and its twist (what only this project has), and what the reader looks at first
STOCK      paper per layer (cardstock / kraft / watercolour / construction / tissue / corrugated), fibre amount
PALETTE    4-7 hex DERIVED from this brief (palettes.md section 3), with roles: ground light/dark, lead family,
           2 contrasting accents, ink, shadow tint, haze; none copied from the example
LIGHT      key colour + direction (azimuth / elevation deg), frontal fill ratio, shadow tint, night / practical lights
LENS       fov, pitch (40-55), sharp band % of frame, max blur px@1080, what overlaps the bottom edge
GROUND     what this world's floor is made of and its own features (deck plates, sand ripples, snow drifts, moss,
           tiles); water only if the brief has it
LAYOUT     the subject's own leading line (a lane, a corridor, a current, a ski run, a channel), landmarks, hero
           position, groups and clearings, kinds of pieces (15-25)
MOTION     mechanisms used, rise / fall timing, stagger, idle sway amplitude, camera behaviour
SOUND      none | flaps + steps (+ music); levels
BANNED     the tells (`look.md` section 12) + anything this piece must not become
QA         the frames / sizes you will capture and what each must show
```

## 3. Pick the build path

Read only what the task needs, when it needs it (all files in `references/`). The minimum before the first frame:

- **3D scene or game:** start from `assets/templates/popup-3d/` (`harness.js` as is + your own `scene.js`); read
  `three-js.md` sections 1, 3, 5, 8, `procedural-art.md` 0, 3, 4, `mechanisms.md` 5, 7, 8, 12, 14, `look.md` 5, 8b,
  11 and `palettes.md` 3.
- **2D scene, illustration, side-scroller:** start from `assets/templates/popup-2d/` (`harness-2d.js` as is + your
  own `scene.js`); the same reading with `web-2d.md` sections 2-3 instead of `three-js.md`.
- **Web page or app UI, HUD, menus:** `paper-ui.md`, `web-2d.md` sections 4-5 (CSS and SVG), `palettes.md` 3.
- **Video:** `motion.md` section 11, then the 2D or 3D path and its `step()` capture.
- **A non-browser engine** (Godot, Unity, Unreal, Blender): `engines.md` (porting notes, untested) and
  `scripts/paper_textures.py` for texture files.

Then, as questions come up:

| Question | Read | Kit |
|---|---|---|
| Your pieces: props, characters, buildings, creatures, machines, plants | `procedural-art.md` | `printCard` + `P.layer` / `P.parts` or `drawnPiece` |
| Your constructions: crosses, box folds, platforms, layered flats, bridges, piers, stairs | `mechanisms.md` (14: built ground) | `hinge`, `crossCard`, `layeredCard`, `boxFold`, `platform`, `WalkField` |
| Timing, springs, puppets, camera | `motion.md` | `FlapSpring`, `windSway`, `FixedClock` (`lib/paper-motion.js`) |
| Endless worlds, a camera that follows the hero, composition | `worlds.md` | the fill in the example `scene.js` |
| Colour; sound and music | `palettes.md`; `sound.md` | `assets/palettes.json`; `lib/paper-sound.js` |
| Planning, measuring, critiquing, finishing | `process.md` | `scripts/measure.py`, `scripts/ab_sheet.py` |

**Write your own pieces.** `assets/lib/` is the plumbing every project in the style may import (to copy it into your
own folder: `three-js.md` section 1, `web-2d.md` section 3). Every THING in your world (trees or coral, houses or
domes, bridges or gantries, creatures, the hero) you design for your subject with the recipes in the references.
`assets/examples/` and the templates' scenes are one countryside world built that way: read them to see how a recipe
becomes code, never assemble a Mars base or a reef from those parts in a new palette; replace the scene, keep the
harness. A construction from `examples/built-ground.js` (`bridge`, `stairs`, `ramp`; `terrace` for built masonry
only) may be imported when it fits, with your prints through `paints`; most briefs need their own (a pier on stilts,
a sagging rope bridge, a gantry), built the same way on `platform`, `boxFold`, `makeCard` and `hinge`.

## 4. Workflow

1. **Spec and target.** Fill the paper spec. If you have one target image (user-supplied or generated), measure it
   with `scripts/measure.py`; otherwise the spec's numbers are the target.
2. **Prove the material on one test card** before building content: one printed card standing on a printed ground,
   under the final light and lens (3D: `?test`, once your scene branches on `H.flags.TEST`: `three-js.md` section 1).
   Check: matte, warm contact shadow, the cut edge (dark line + lit-side highlight), fibre visible but quiet, sharp
   band and blur where expected. Fix here; every later asset inherits it.
3. **Design and build your pieces, then the world.** List the 15-25 kinds of piece your subject needs and design each:
   silhouette (chunky, convex lobes, flat base), construction (`mechanisms.md`) and print (law 4, `procedural-art.md`
   section 3); the hero as in law 8. Prove two or three kinds on the test card, then landmarks and the leading line by
   hand, then the fill of groups and clearings (law 8). Build what the hero walks on, under or into first (law 9) and
   wire its walk surface (`WalkField`) before dressing around it.
4. **Motion.** Hinges and springs from `motion.md`. Rise in flat-stack order: the card lying on top when folded rises
   first (3D cards fold back, so the nearest first; 2D cards fold forward, so the farthest first), staggered; closing
   is the exact reverse.
5. **Sound** (optional) from `sound.md`; keep it quieter and sparser than feels necessary.
6. **Capture deterministically.** Seed every random choice and drive motion from a fixed-step clock, never wall time.
   Both harnesses expose `restart()` (everything flat, t = 0), `step(seconds)` and `resume()`; every review frame is
   `restart(); step(T)`, never a grab of the free-running loop. Capture the settled hero frame, a mid-rise frame and
   a wide frame.
7. **Measure, then critique.** `python scripts/measure.py frame.png [--target target.png]` is a gate, not proof:
   `--profile storybook` (default: day, dusk and pitched 2D worlds), `night`, or `flat` (UI pages and print only);
   `--crop x,y,w,h` for a scene inside a page; `--palette` with your spec's hexes when there is no target image. Then
   compare blind against the target (`scripts/ab_sheet.py`), fix the top three problems, and repeat at most three
   rounds (no target: judge by section 7 and `look.md` section 11). Refine rather than add. With a time box, reach the
   first full frame by half of it and spend the rest on these rounds (stopping at the first frame left stamped
   clones, straight ground edges and an empty middle).
8. **Report honestly** what was verified (with the frames) and what was not.

## 5. Fake-paper tells (ban list)

The tells that make a frame read as CG instead of paper, each with the fix that worked, are in one list:
`references/look.md` section 12. Read it before the first review round and again before you report.

## 6. Starting values

Every number that held up (thickness, print layers, step sizes, light, shadow tint, lens, grade, flap timing, sway,
sound) is in one table: `references/look.md` section 11; density and sizes against the hero are in
`references/worlds.md` sections 8-9.

## 7. Check the render

After every visual change, capture the same frames and look at them at 100 % and at 3x crops:

- [ ] Ground past every edge; no sky, horizon, table or book edge; the camera 40-55 degrees down.
- [ ] A full model world: groups of different chunky pieces, the sharp band packed (barePct <= ~55), open ground
      mostly outside it, a leading line, the hero off-centre, big blurred pieces at the bottom edge.
- [ ] No stamped repeats: 4-6 seeded variants per kind (outline, size +-15 %, print), twins 3+ piece-widths apart,
      no open patch over ~1/6 of the frame without a group.
- [ ] Palette, ground print and leading lines are this brief's: no colour taken from the example scene or a starting
      palette as it is, no river, path or watercolour-wash formula unless the subject has them (a renamed river, a
      "channel" or "stream" with a torn rim and foam ripples, is the same leak); one leading line unless the subject
      has two routes.
- [ ] No straight ground edge over ~15 % of the frame width: leading lines bend twice in frame, region borders are
      torn with a pale fibrous fringe; the middle gets volume from nested landforms (3-5 cards stepped in value).
- [ ] The hero is a 3D paper model that reads from the front, the side and the back and turns to face the way it
      walks (never one flat card): limbs that stride, a readable face, costume detail, chunky toy-like proportions,
      colours that contrast with the ground, inside the sharp band.
- [ ] Nothing glossy; under ~1 % clipped pixels; the darkest 20 % warm (navy at night), never grey.
- [ ] A contact shadow under every standing piece; cast shadows where the camera sees them; camera-facing cards not
      grey.
- [ ] Cut edges: a thin dark line and a pale highlight on the lit side only; no halo, no edge-on slivers, no
      stair-stepped edges, nothing along folds.
- [ ] Every print a layered collage (3+ values, lip + short shadow, an ornament, a contrasting accent) designed for
      this subject; never a flat fill, a thin ink drawing or a fill with noise, never a countryside example.
- [ ] Everything walked on, under or into is built open and walked by the hero: feet on the surface, never inside a
      rail or floating; water and walls stop him.
- [ ] One sharp band (~36-45 % of the frame height) on the subject; top and bottom blurred; nothing important blurred.
- [ ] Palette within the spec: no video-game greens, cream whites, warm inks, no colour fog.
- [ ] Motion: hinge rotation only; one overshoot, settled by ~1 s; nothing pops in. Sound (if any) quieter than the
      music, never constant.

## 8. Gotchas

- **Clock, fps, build cost:** clamp the real-time step to [0, 0.05] s (a slow build can make the first frame's
  timestamp older than the clock you read before it, and a negative step runs every spring backwards); measure fps in
  the live loop, never by timing `step()`; a layered print costs ~10-30 ms. Traps and levers: `three-js.md` sections
  8-10, `web-2d.md` section 3.
- **Image generation is optional** (`image-gen.md`, when available and allowed). Never block on it; everything in
  this skill is reachable procedurally.
- **Taste comes from a human.** Metrics and critics push toward more (more bob, more sound, more detail); the owner
  of the source project kept asking for calmer, quieter, subtler. When in doubt, take something away.
