---
name: papercraft-godot
description: Build handcrafted pop-up papercraft games, dioramas, UI and motion natively in Godot 4, using extruded cut-card meshes, layered print shaders, physical folds, soft world-tinted shadows, tilt-shift framing and fixed-step spring motion. Use when a Godot scene should look, move or sound like printed cardstock, a pop-up book or a paper diorama. Not for browser/three.js builds, printable craft patterns, or paper as a document medium.
license: MIT
metadata:
  author: R-Lui; adapted from xikhar/papercraft
  upstream: https://github.com/xikhar/papercraft
  compatibility: Godot 4.4 or newer. Reference implementation and demo tested with Godot 4.7.2 on macOS.
  version: "1.0.0"
---

# Papercraft for Godot

Build the world as a photographed paper model: cut, folded and layered cardstock standing on a printed
ground, seen through a long macro lens. The look comes from geometry, print, light and motion in Godot, not
from a web canvas embedded in the game.

The brief decides the subject, palette, pieces and life. This skill decides how those things become paper.
Use the runnable project in `assets/demo/` as a working material proof and starting scaffold, then replace its
subject-specific pieces.

## The look laws

1. **Flat sheet plus thickness.** Every standing piece is an extruded cut silhouette. Use 1.5-3% of hero
   height for card thickness. Never rely on a zero-thickness `QuadMesh` except for ground prints and decals.
2. **Matte.** Roughness 1, no metallic or specular, no environment reflections. A custom wrap-light shader is
   preferable to glossy PBR.
3. **Layered print.** Give every silhouette 3-5 inks in at least 3 value steps plus one countable motif. Each
   larger layer gets a short warm shadow and a pale lit lip. Avoid flat fills, thin line art and AI-like noise.
4. **A real cut edge.** Print a thin dark-brown contour at the silhouette and a highlight only on its
   upper-light side. Darken side faces to roughly 0.5-0.55 of the print value; do not add a white sticker rim.
5. **Warm key, coloured shadows.** Place a warm key 45-60 degrees above and 45-65 degrees to the side, with a
   frontal fill at one quarter to one third of the key. Tint ambient light toward the world's shadow colour.
   Every standing card visibly meets the ground.
6. **Macro lens.** Use a 24-32 degree vertical FOV, camera pitch 40-55 degrees down, hero 6-10% of frame
   height, and printed ground running past every edge. No horizon, sky, table or scene border.
7. **Tilt-shift focus.** Keep roughly 36-45% of frame height visibly crisp through the hero, then blur toward
   the top and bottom. A screen-height post shader is sufficient for a fixed camera; use depth too for moving
   cameras. See `references/godot-4.md`.
8. **Chunky, layered world.** Build dense groups of 15-25 kinds of pieces. Slotted crosses make round objects
   read from every side; bushes and foreground dressing are layered flats. Vary size, outline and print with
   a seeded random generator, not stamped clones.
9. **Built walkable space.** Floors, decks, ramps and stairs are open constructions on stringers or posts,
   never solid terrain blocks. If something is walked on, a collision surface belongs at the same height.
10. **Rotation, not squash.** Hinges rotate around a crease pivot. Rise with a small overshoot and settle in
    about 0.8-1 second; stagger pieces 0.05-0.1 seconds. Keep idle sway subtle and avoid scale pops.
11. **Soft paper sound.** Optional foley is short, low and sparse: card taps, folds and dry shuffles, never a
    continuous loop under every gesture.
12. **Visible life.** Add 3-5 environment-specific motions such as leaves, motes, butterflies, smoke or wind
    drift. Keep them sparse enough that a still frame shows only a few.

## Native Godot rules

- Build the art in a `SubViewport`, as generated `ImageTexture`s, or in a custom editor tool. Do not require
  a browser canvas, HTML overlay, npm package or three.js runtime.
- Cut-card geometry uses an `ArrayMesh`: front and back caps plus side strips. Keep the hinge pivot at the
  bottom crease so `rotation.x` is the fold.
- Use `ShaderMaterial` with a Godot `spatial` shader for paper surfaces. Use `StandardMaterial3D` only for
  quiet backing sheets and ground prints.
- Use `_physics_process()` or a fixed-step timer for deterministic folding. `Tween` is fine for presentation
  once the timing is known. Do not drive animation from wall-clock noise.
- Post-process with `hint_screen_texture` in a `CanvasLayer` or with a `CompositorEffect`. Keep UI on a higher
  canvas layer when a screen-height blur is active.
- Keep the 3D scene in `Node3D` and readable HUD text in Godot `Control` nodes.

## Before building: paper spec

Write this short block into the scene script or plan:

```text
BRIEF     place, mood, must-haves, must-nots, supplied references
SUBJECT   what the player sees first and what makes this world specific
PALETTE   ground / lead / accent / ink / shadow tint / highlight, as hex roles
LIGHT     key colour and direction, fill ratio, ambient shadow tint
LENS      FOV, pitch, focus line, sharp band, max blur
FORMAT    viewport size, aspect, safe area
GROUND    paper stock, printed regions, leading line
PIECES    15-25 kinds, each with structure type and print motifs
MOTION    hinge order, stagger, overshoot, idle amplitudes
LIFE      3-5 environmental motions
QA        which frames prove material, framing and folds
```

Do not copy the demo's jungle palette or props into another brief. Derive colours from the subject and keep
ground slightly lighter and quieter than the cards.

## Build path

1. Read `references/look.md` for material, light, palette and anti-CG checks.
2. For Godot implementation details, read `references/godot-4.md`.
3. Read `references/art-direction.md` for structures, printable motifs, hero construction and UI.
4. Copy `assets/demo/` as a scaffold only when starting a new isolated project. Keep its code if useful;
   replace its subject, palette, arrangement and generated print functions.
5. Prove one extruded card on one ground sheet under the final light and camera. Check thickness, silhouette,
   print layers, cut edge and contact shadow before growing the world.
6. Build the hero's walkable surface first, then landmarks, leading line, fill groups, life and HUD.
7. Capture a settled frame, a mid-fold frame and a wide gameplay frame. Inspect at 100%; fix only the largest
   style failures and stop after three rounds.

## Demo and verification

The demo is a self-contained Godot 4.7 project:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path skills/papercraft-godot/assets/demo
```

In the demo:

- `SPACE` folds the diorama flat and raises it again.
- Click a card to make it hop.
- `C` captures `user://papercraft_demo.png`.
- `--smoke` validates scene construction and exits.
- `--capture=/absolute/path.png` waits for the popup to settle, saves a frame and exits.

Automated check:

```bash
skills/papercraft-godot/scripts/check_demo.sh
```

The check must run headlessly with no script/shader errors, then capture at least one real rendered PNG.

## Stop conditions

- If the scene reads as glossy CG, flat vector art or stickers, fix material and silhouette before adding more
  props.
- If a card is edge-on or knife-thin, extrude it and turn it toward the camera.
- If the hero clips another card, redesign the footprint rather than adding an outline.
- If the frame has a horizon, table edge or empty middle, change camera and density.
- If two refinement attempts do not converge, show the frame and ask for a concrete visual correction.

## Attribution

Adapted from `xikhar/papercraft` (MIT). Keep the upstream license with distributed copies of the skill and
content derived from it.
