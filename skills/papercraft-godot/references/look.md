# Paper material, light and framing

Use this when authoring materials, lights, palette or the review gate. Values are starting points; the brief wins.

## Material

- Card thickness: 1.5-3% of hero height. A 1.5 m hero uses roughly 2.5-4.5 cm.
- Faces are matte: roughness 1, metallic 0, specular off.
- Use wrap diffuse around 0.30 by day and 0.38-0.42 at night. This avoids the plastic Lambert terminator.
- Shadows should leak the world's bounce colour. Warm daylight shadow tint examples: `#6f3f1e`, `#7c4b27`,
  `#53341f`. Snow uses lilac-blue; night uses navy; reef scenes use deep teal.
- Paper fibre stays locked to the surface. Use two quiet scales and keep variation within about 3-6%.

## Layered print

For every card:

1. Fill the silhouette with a base ink.
2. Add a large tonal shape, 10-15% darker or lighter.
3. Add two supporting layers at further value steps.
4. Add one contrasting accent and one countable ornament family.
5. Put a short warm shadow below/behind layers and a pale highlight on upper-left layer edges.
6. Print a thin dark contour at the outer cut. Highlight only the upper-left contour, never the whole outline.

Aim for three value steps and at least one large motif in every 100-150 px of card at 1080p. Avoid one-pixel
detail, speckle used as texture, soft gradients, glow and wire-like linework.

## Light

| Role | Starting value |
|---|---|
| Key | warm cream/amber, 45-60 degrees elevation |
| Fill | frontal, 25-33% of key |
| Ambient | muted bounce colour, never neutral grey |
| Contact | tight local darkening where card meets floor |
| Cast shadow | sideways/behind, penumbra 25-30% of caster height |

Keep clipped highlights under about 1%. Don't add fog over the whole frame; distant haze belongs only beyond
the readable area and should be a quiet mid-tone.

## Palette

Choose 4-7 roles:

- ground light and dark;
- one lead family carried by the pieces;
- two contrasting accents;
- ink/cut-edge brown;
- shadow tint;
- highlight cream.

Ground is usually brighter and less saturated than the standing cards. Avoid pure white and pure black. In a
colourful day scene, HSV saturation often sits around 0.55-0.75; snow/mist scenes can be near 0.15.

## Camera and focus

- 24-32 degree vertical FOV.
- 40-55 degree downward pitch.
- Hero 6-10% of 16:9 frame height.
- Hero off-centre and near the sharp band.
- Printed ground to every frame edge.
- Sharp band roughly 36-45% of frame height.
- At 1080p, far blur can reach 12-18 px radius and near blur may reach it sooner.
- Put a large, heavily blurred card across the lower edge to strengthen the miniature scale.

For a fixed camera, a screen-height tilt-shift shader is enough. For a moving camera, blend screen height with
depth so upright cards do not sharpen simply because they cross the horizontal line.

## Fake-paper tells

Reject:

- flat zero-thickness sprites;
- glossy or wet specular;
- grey neutral shadows;
- white halo around every silhouette;
- even pale border around every layer;
- vector-flat fills without layered print;
- sky, horizon, table or scene border;
- uniform stamped trees/props;
- cards cutting through the hero;
- constant bobbing, scale breathing or squash;
- a vast empty middle;
- blur that misses the hero or wipes out the UI.

## QA frames

Capture:

1. **Material:** one card close enough to inspect cut edge, print layers and grain.
2. **Mid-fold:** cards partially raised, staggered, with no pop or scale cheat.
3. **Settled gameplay:** full world, hero readable, ground fills frame, focus band packed.

Inspect each at 100%. Compare against the same camera between rounds.
