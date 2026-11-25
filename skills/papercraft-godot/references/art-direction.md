# Papercraft art direction in Godot

## Structures

- **Flat print:** floor, map, tile, path, decal. No thickness; shadows optional.
- **Single card:** bush, grass clump, shallow prop. Usually faces camera within 14 degrees.
- **Layered card:** rock, clothing panel, sign, stage backdrop. Stack 3-5 silhouettes 2-5% of object height apart.
- **Cross card:** tree, palm, post, tent, round prop. Two printed silhouettes slotted at 90 degrees.
- **V-fold / half cross:** creature wing, open tent, foldable screen.
- **Box / prism fold:** house, shrine, stall, crate. Build walls as open cards around a floor rather than a solid cube.
- **Platform:** deck on posts, stairs on stringers, ramp with side cards and a tread surface.

Do not build everything as a stack of flat billboards. Anything the camera circles must read from two planes.

## Hero

For a 3D scene, the hero should read at multiple angles:

- torso and head as shallow extruded cards;
- two leg cards hinged at hips;
- arm cards hinged at shoulders;
- one backing piece for the cape/coat;
- small cross-plane detail for nose, hair or weapon only when needed.

Lay out the limb cards so walking never cuts through the torso. A simple readable face beats a detailed face
that flickers. Toy proportions work: head about 1/4-1/3 of height.

For a pure board-game HUD, one upright die-cut standee is acceptable; it is a physical game piece rather than
a walking hero.

## Print themes

Derive 6-10 motifs from the subject:

- architecture: bricks, scallops, planks, carved keys;
- plants: leaf lobes, veins, berry clusters, fronds;
- creatures: scales, feather bars, paw pads, shell spirals;
- mechanics: rivets, panels, rivet shadows, hazard chevrons;
- culture: textile bands, geometric saddle patterns, tilework.

Make the silhouettes countable and chunky. Motifs should be large enough to survive the tilt-shift blur.

## Palette roles

Keep one lead family across the world. Use accents where the player should look:

- hero clothing accent;
- interactable mark;
- enemy danger mark;
- one repeated environmental accent.

If the ground and cards have similar saturation, pieces dissolve together. Keep ground quieter.

## Dressing density

Compose in groups:

- one large landmark;
- 2-4 medium objects;
- 4-8 small pieces in a tight cluster;
- open ground only outside the sharp band or as a deliberate clearing;
- one leading line, curved at least twice in frame.

Seed 4-6 variants per prop kind: outline width, 10-15% height change, motif count, small yaw. Separate twins by
at least three piece widths.

## UI in Godot

- Default to no HUD chrome. Show one fading hint, then use in-world paper, lamps or tokens.
- When a screen is required, use a paper sheet with neatline, cream page, dark-brown ink and one accent.
- Use `PanelContainer` with a generated paper `StyleBoxTexture`, not a generic translucent rounded rectangle.
- Keep text as real `Label`/`RichTextLabel` text for localization and accessibility.
- Paper UI motion is a hinge or sheet slide with a shadow ahead of its edge, not a generic fade.

## Life

Choose 3-5 from the world, not all of them:

- drifting leaves or petals;
- dust motes;
- snow or ash;
- butterflies or birds;
- smoke curls;
- water ripples;
- fireflies;
- a small creature with one idle and one flee/feed action.

Use `GPUParticles3D` when the motion is repetitive, but make the particle mesh a tiny printed paper piece.
Use tweens/state machines for countable creatures so their actions read.
