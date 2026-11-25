# Native Godot 4 recipes

Reference implementation: `assets/demo/`. Tested on Godot 4.7.2 Forward+.

## Extruded cut-card mesh

Validate a normalized 2D outline with `Geometry2D.triangulate_polygon()`. Generate:

- front cap at `+thickness/2`;
- back cap at `-thickness/2`;
- one side quad per outline segment;
- UVs from the outline's bounding box;
- front/back material on surface 0, darkened side material on surface 1.

Map normalized `(x, y_down)` to world `(x - 0.5) * width, (1 - y) * height`. Keep local y from zero to height,
then place the mesh under a `Node3D` hinge pivot. Rotating the pivot around x is the fold.

See `assets/demo/paper_card.gd`.

## Paper surface shader

`assets/demo/paper_surface.gdshader` contains a production-safe starting shader:

- custom wrap diffuse;
- shadow attenuation mixed toward a world bounce colour;
- surface-locked two-scale grain;
- back-face kraft treatment;
- optional hit flash;
- no specular.

Keep the cut contour painted into the printed texture rather than faking a white shader outline. The geometry
already owns the true silhouette and casts a correct shaped shadow.

## Ground and shadows

- Use a `PlaneMesh` with `StandardMaterial3D` roughness 1 and specular disabled.
- Tile a generated paper fibre texture at two scales.
- Use `DirectionalLight3D` with shadows enabled. Keep the shadow distance tight around the diorama so contact
  detail survives.
- Set `Environment.ambient_light_source = AMBIENT_SOURCE_COLOR`, a warm bounce colour, and low energy.
- Enable SSAO only when it improves layer contact; tint it with the same warm/cool role as the world shadow.
- If transparent alpha textures are used, make shadow casters use matching alpha scissor or replace them with
  extruded geometry. Rectangular shadows under cut trees are a hard tell.

## Tilt-shift

For a fixed camera, use a full-screen `CanvasLayer` with a `ColorRect` and this pattern:

```glsl
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float focus_y = 0.55;
uniform float sharp_band = 0.30;
uniform float blur_px = 10.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    float d = abs(uv.y - focus_y);
    float amount = smoothstep(sharp_band * 0.5, 0.58, d);
    vec2 radius = SCREEN_PIXEL_SIZE * blur_px * amount;
    vec3 col = texture(screen_texture, uv).rgb;
    // Add centre-weighted taps in a 12-direction disc here.
    COLOR = vec4(col, 1.0);
}
```

Use a higher canvas layer for HUD text. For a moving camera, read depth and reconstruct view distance. Merge
the screen-height CoC with a depth CoC; the skill's 38% depth mix is a useful start.

## Hinge motion

Start flat at about `-90` degrees around x. Rise to zero with an overshoot and small settle:

```gdscript
var tween := create_tween()
tween.tween_interval(delay)
tween.tween_property(pivot, "rotation_degrees:x", -2.0, 0.42) \
    .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
tween.tween_property(pivot, "rotation_degrees:x", 0.0, 0.22) \
    .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
```

After settling, apply small seeded yaw sway in `_process()` or `_physics_process()`. Never scale the card to
fake a pop.

## Interaction

- Put an `Area3D` and `CollisionShape3D` on each card for click input.
- Enable `Viewport.physics_object_picking` if using `input_event`.
- Emit a card-local signal; let the scene own consequences.
- Keep simulation state separate from card animation nodes.

## Determinism

- Use one `RandomNumberGenerator` per generated piece, seeded from stable IDs.
- Use a fixed physics tick for gameplay-affecting folds and effects.
- Make replay reconstruct hinge states from elapsed time rather than reading wall time.

## Capture

For a visual smoke test, wait for `RenderingServer.frame_post_draw`, then read the viewport texture:

```gdscript
await RenderingServer.frame_post_draw
var image := get_viewport().get_texture().get_image()
var error := image.save_png(output_path)
```

Headless mode is enough to catch parse and construction errors, but use a real renderer for the final image.

## Common Godot pitfalls

- `QuadMesh` has no thickness and reads as a sprite.
- A `Sprite3D` shadow is rectangular unless its shadow mode and alpha handling are configured.
- `StandardMaterial3D` defaults can leave specular sheen; set specular mode disabled.
- Screen textures in CanvasItem shaders must be on a layer above the 3D render and below interactive UI.
- Don't animate node scale to simulate paper springing.
- Don't set the hinge pivot at the mesh center.
- Don't use one giant extruded card when a cross of two cards makes a round object.
