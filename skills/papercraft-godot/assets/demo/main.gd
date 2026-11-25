extends Node3D

const COLORS := {
	"ground": Color("#c7b996"),
	"ground_light": Color("#ddd0b0"),
	"ground_dark": Color("#9f8b69"),
	"ink": Color("#3a281b"),
	"cream": Color("#f2e4c5"),
	"moss": Color("#87925a"),
	"moss_dark": Color("#5b6943"),
	"moss_light": Color("#b8b66e"),
	"stone": Color("#a77b53"),
	"stone_dark": Color("#6d4b35"),
	"stone_light": Color("#d0aa78"),
	"crimson": Color("#a5462d"),
	"gold": Color("#d7a43d"),
	"blue": Color("#466e79"),
	"path": Color("#e3d2ad"),
}

var _cards: Array[PaperCard] = []
var _leaves: Array[Dictionary] = []
var _capture_path := ""
var _smoke_mode := false
var _dump_art := false
var _hint: Label
var _elapsed := 0.0

func _ready() -> void:
	_parse_args()
	get_viewport().physics_object_picking = true
	_build_environment()
	_build_ground()
	_build_path()
	_build_world()
	_build_life()
	_build_tilt_shift()
	_build_hint()
	_replay()

	if not _capture_path.is_empty():
		_capture_when_ready()
	elif _smoke_mode:
		_run_smoke_test()

func _process(delta: float) -> void:
	_elapsed += delta
	_animate_life(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_replay()
		elif event.keycode == KEY_C:
			_capture_to("user://papercraft_demo.png")
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--smoke":
			_smoke_mode = true
		elif arg == "--dump-art":
			_dump_art = true
		elif arg.begins_with("--capture="):
			_capture_path = arg.trim_prefix("--capture=")

func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = COLORS["ground"]
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#7b6a54")
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.tonemap_exposure = 0.90
	# The demo's cards are thin double-sided slabs; screen-space AO between the
	# two caps darkens their faces. Directional contact shadows carry the depth.
	environment.ssao_enabled = false
	world_env.environment = environment
	add_child(world_env)

	var key := DirectionalLight3D.new()
	key.name = "WarmKey"
	key.rotation_degrees = Vector3(-51.0, -37.0, 0.0)
	key.light_color = Color("#ffe9cf")
	key.light_energy = 0.92
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 28.0
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	add_child(key)

	var fill := OmniLight3D.new()
	fill.name = "FrontFill"
	fill.position = Vector3(5.5, 5.0, 8.0)
	fill.light_color = Color("#f8ead4")
	fill.light_energy = 0.62
	fill.omni_range = 22.0
	fill.shadow_enabled = false
	add_child(fill)

	var camera := Camera3D.new()
	camera.name = "MacroCamera"
	camera.position = Vector3(5.7, 7.8, 8.9)
	camera.fov = 28.0
	camera.near = 0.1
	camera.far = 80.0
	add_child(camera)
	camera.look_at_from_position(camera.position, Vector3(0.0, 0.1, -0.7), Vector3.UP)
	camera.current = true

func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "PrintedGround"
	var plane := PlaneMesh.new()
	plane.size = Vector2(32.0, 25.0)
	ground.mesh = plane
	ground.position = Vector3(0.0, 0.0, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = COLORS["ground"]
	material.albedo_texture = _make_ground_texture()
	material.roughness = 1.0
	material.metallic = 0.0
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	material.uv1_scale = Vector3(3.2, 3.2, 1.0)
	ground.material_override = material
	add_child(ground)

	for i in range(3):
		var hill := CylinderMesh.new()
		hill.top_radius = 2.8 - float(i) * 0.35
		hill.bottom_radius = hill.top_radius
		hill.height = 0.035
		hill.radial_segments = 48
		var hill_node := MeshInstance3D.new()
		hill_node.name = "NestedHill%d" % (i + 1)
		hill_node.mesh = hill
		hill_node.position = Vector3(-3.6 + float(i) * 3.4, 0.018 + float(i) * 0.006, -5.1)
		hill_node.rotation_degrees.x = 90.0
		hill_node.scale = Vector3(2.05, 1.0, 0.56)
		var hill_mat := StandardMaterial3D.new()
		hill_mat.albedo_color = [
			Color("#7f8a5b"),
			Color("#92996a"),
			Color("#a9aa76")
		][i]
		hill_mat.roughness = 1.0
		hill_mat.metallic_specular = 0.0
		hill_node.material_override = hill_mat
		add_child(hill_node)

func _build_path() -> void:
	for i in range(11):
		var tile := MeshInstance3D.new()
		tile.name = "PathTile%02d" % i
		var plane := PlaneMesh.new()
		plane.size = Vector2(0.72 - float(i) * 0.018, 0.58)
		tile.mesh = plane
		var t := float(i) / 10.0
		var position_value := Vector3(2.9 - 2.5 * t + 0.58 * sin(t * PI), 0.028, 2.8 - 5.0 * t)
		tile.position = position_value
		tile.rotation_degrees = Vector3(-90.0, 8.0 * sin(t * TAU), 6.0)
		var material := StandardMaterial3D.new()
		material.albedo_color = COLORS["path"].lerp(COLORS["ground_light"], t * 0.25)
		material.roughness = 1.0
		material.metallic_specular = 0.0
		tile.material_override = material
		add_child(tile)

		var edge := MeshInstance3D.new()
		var edge_plane := PlaneMesh.new()
		edge_plane.size = plane.size + Vector2(0.08, 0.08)
		edge.mesh = edge_plane
		edge.position = position_value - Vector3(0.0, 0.006, 0.0)
		edge.rotation_degrees = tile.rotation_degrees
		var edge_material := StandardMaterial3D.new()
		edge_material.albedo_color = Color("#6b4a2d")
		edge_material.roughness = 1.0
		edge_material.metallic_specular = 0.0
		edge.material_override = edge_material
		add_child(edge)

func _build_world() -> void:
	var tree_outline := _tree_outline()
	var bush_outline := _bush_outline()
	var arch_outline := _arch_outline()
	var hero_outline := _hero_outline()
	var die_outline := _rounded_card_outline()
	var rock_outline := _rock_outline()
	var lantern_outline := _lantern_outline()
	var tree_texture_a := _make_tree_art(
		tree_outline, Color("#596b3f"), Color("#8b9c56"), Color("#c6c377"), 11
	)

	_add_card(
		"JungleTreeA",
		tree_outline,
		Vector2(2.2, 3.0),
		tree_texture_a,
		Vector3(-3.25, 0.0, -2.8),
		-15.0
	)
	_add_card(
		"JungleTreeACross",
		tree_outline,
		Vector2(2.18, 2.98),
		tree_texture_a,
		Vector3(-3.25, 0.0, -2.8),
		76.0
	)
	_add_card(
		"JungleTreeB",
		tree_outline,
		Vector2(1.65, 2.6),
		_make_tree_art(tree_outline, Color("#526344"), Color("#7d8d57"), Color("#c0b66c"), 29),
		Vector3(2.75, 0.0, -4.0),
		12.0
	)
	_add_card(
		"TempleArch",
		arch_outline,
		Vector2(2.7, 2.25),
		_make_arch_art(arch_outline),
		Vector3(-0.35, 0.0, -4.25),
		0.0
	)
	_add_card(
		"BushLeft",
		bush_outline,
		Vector2(1.35, 0.95),
		_make_bush_art(bush_outline, Color("#617145"), Color("#99a762"), Color("#d9be58"), 47),
		Vector3(-4.7, 0.0, 1.3),
		22.0
	)
	_add_card(
		"BushRight",
		bush_outline,
		Vector2(1.15, 0.82),
		_make_bush_art(bush_outline, Color("#5b7048"), Color("#9bac66"), Color("#bd6742"), 53),
		Vector3(3.8, 0.0, 0.55),
		-18.0
	)
	_add_card(
		"IsekaiHero",
		hero_outline,
		Vector2(0.88, 1.50),
		_make_hero_art(hero_outline),
		Vector3(0.25, 0.0, 0.55),
		-4.0
	)
	_add_card(
		"CardboardDie",
		die_outline,
		Vector2(0.9, 0.9),
		_make_die_art(die_outline),
		Vector3(2.65, 0.0, 1.65),
		18.0
	)
	_add_card(
		"ForegroundGrass",
		bush_outline,
		Vector2(2.3, 1.35),
		_make_bush_art(bush_outline, Color("#4e6043"), Color("#7d9055"), Color("#d5a84c"), 67),
		Vector3(-2.4, 0.0, 3.65),
		-26.0
	)
	_add_card(
		"LeafClusterA",
		bush_outline,
		Vector2(0.82, 0.58),
		_make_bush_art(bush_outline, Color("#627449"), Color("#9aaa65"), Color("#c7663c"), 73),
		Vector3(-1.25, 0.0, 1.28),
		8.0
	)
	_add_card(
		"LeafClusterB",
		bush_outline,
		Vector2(0.72, 0.52),
		_make_bush_art(bush_outline, Color("#596d45"), Color("#91a05d"), Color("#d9bf5e"), 79),
		Vector3(1.7, 0.0, -0.38),
		-12.0
	)
	_add_card(
		"LeafClusterC",
		bush_outline,
		Vector2(0.64, 0.46),
		_make_bush_art(bush_outline, Color("#617049"), Color("#a3ac6a"), Color("#b75e3d"), 89),
		Vector3(-2.75, 0.0, -0.15),
		17.0
	)
	_add_card(
		"RockLeft",
		rock_outline,
		Vector2(1.08, 0.66),
		_make_rock_art(rock_outline, 101),
		Vector3(-1.75, 0.0, -1.55),
		9.0
	)
	_add_card(
		"RockRight",
		rock_outline,
		Vector2(0.88, 0.54),
		_make_rock_art(rock_outline, 109),
		Vector3(3.0, 0.0, -0.68),
		-14.0
	)
	_add_card(
		"PathLanternLeft",
		lantern_outline,
		Vector2(0.46, 0.92),
		_make_lantern_art(lantern_outline),
		Vector3(-0.85, 0.0, -1.72),
		-8.0
	)
	_add_card(
		"PathLanternRight",
		lantern_outline,
		Vector2(0.42, 0.84),
		_make_lantern_art(lantern_outline),
		Vector3(1.95, 0.0, -2.4),
		9.0
	)

func _add_card(
	value_name: String,
	value_outline: PackedVector2Array,
	size: Vector2,
	texture: Texture2D,
	position_value: Vector3,
	yaw: float
) -> void:
	var card := PaperCard.new()
	card.name = value_name
	card.position = position_value
	card.rotation_degrees.y = yaw
	add_child(card)
	card.setup(value_name, value_outline, size, texture, _stable_seed(value_name), 0.0)
	card.card_clicked.connect(func(clicked_card: PaperCard) -> void: clicked_card.hop())
	_cards.append(card)

func _replay() -> void:
	for i in range(_cards.size()):
		var card := _cards[i]
		card.call_deferred("pop_up", float(i) * 0.055)

func _build_tilt_shift() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TiltShiftLayer"
	layer.layer = 1
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = load("res://tilt_shift.gdshader")
	material.set_shader_parameter("focus_y", 0.53)
	material.set_shader_parameter("sharp_band", 0.31)
	material.set_shader_parameter("max_blur_px", 9.5)
	rect.material = material
	layer.add_child(rect)
	add_child(layer)

func _build_life() -> void:
	var gold_leaf := _make_leaf_art(Color("#d9a845"), 127)
	var red_leaf := _make_leaf_art(Color("#b85b3d"), 131)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026112601
	for i in range(16):
		var leaf := MeshInstance3D.new()
		leaf.name = "FallingPaperLeaf%02d" % i
		var quad := QuadMesh.new()
		quad.size = Vector2(0.16, 0.085) * rng.randf_range(0.72, 1.15)
		leaf.mesh = quad
		var material := StandardMaterial3D.new()
		material.albedo_texture = gold_leaf if i % 3 else red_leaf
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.alpha_scissor_threshold = 0.44
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		leaf.material_override = material
		leaf.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		leaf.position = Vector3(
			rng.randf_range(-5.2, 4.8),
			rng.randf_range(1.0, 5.0),
			rng.randf_range(-4.4, 2.5)
		)
		leaf.rotation_degrees = Vector3(
			rng.randf_range(-45.0, 45.0),
			rng.randf_range(0.0, 360.0),
			rng.randf_range(-30.0, 30.0)
		)
		add_child(leaf)
		_leaves.append({
			"node": leaf,
			"fall_speed": rng.randf_range(0.09, 0.20),
			"drift_speed": rng.randf_range(0.35, 0.85),
			"drift_phase": rng.randf_range(0.0, TAU),
			"spin": rng.randf_range(-0.8, 0.8),
		})

func _animate_life(delta: float) -> void:
	for leaf_data in _leaves:
		var leaf := leaf_data["node"] as MeshInstance3D
		leaf.position.y -= float(leaf_data["fall_speed"]) * delta
		leaf.position.x += sin(
			_elapsed * float(leaf_data["drift_speed"]) + float(leaf_data["drift_phase"])
		) * delta * 0.10
		leaf.rotation.z += float(leaf_data["spin"]) * delta
		if leaf.position.y < 0.14:
			leaf.position.y = 5.2

func _build_hint() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HintLayer"
	layer.layer = 2
	_hint = Label.new()
	_hint.text = "SPACE  FOLD AGAIN       CLICK A CARD  HOP       C  CAPTURE"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 15)
	_hint.add_theme_color_override("font_color", Color(1.0, 0.92, 0.74, 0.80))
	_hint.add_theme_color_override("font_shadow_color", Color(0.15, 0.09, 0.04, 0.70))
	_hint.add_theme_constant_override("shadow_offset_x", 1)
	_hint.add_theme_constant_override("shadow_offset_y", 2)
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.offset_left = -320.0
	_hint.offset_right = 320.0
	_hint.offset_top = -60.0
	_hint.offset_bottom = -30.0
	layer.add_child(_hint)
	add_child(layer)

func _capture_when_ready() -> void:
	await get_tree().create_timer(2.25).timeout
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(_capture_path)
	if error == OK:
		print("PAPERCRAFT_CAPTURE_OK path=%s size=%s" % [_capture_path, image.get_size()])
		get_tree().quit(0)
	else:
		push_error("PAPERCRAFT_CAPTURE_FAILED error=%d" % error)
		get_tree().quit(2)

func _capture_to(path_value: String) -> void:
	_capture_path = path_value
	_capture_when_ready()

func _run_smoke_test() -> void:
	await get_tree().create_timer(1.8).timeout
	var failures: Array[String] = []
	if _cards.size() < 8:
		failures.append("expected at least 8 paper cards")
	if _leaves.size() < 3:
		failures.append("expected ambient paper life")
	if get_node_or_null("TiltShiftLayer") == null:
		failures.append("tilt-shift layer missing")
	var mesh_count := 0
	for card in _cards:
		if card.card_size.x <= 0.0 or card.card_size.y <= 0.0:
			failures.append("%s has invalid size" % card.card_name)
		var mesh := card.get_node_or_null("HingePivot/PrintedCard") as MeshInstance3D
		if mesh == null or mesh.mesh == null or mesh.mesh.get_surface_count() != 2:
			failures.append("%s lacks extruded mesh surfaces" % card.card_name)
		else:
			mesh_count += 1
		var hinge := card.get_node_or_null("HingePivot") as Node3D
		if hinge == null or absf(hinge.rotation_degrees.x) > 0.4:
			failures.append("%s did not settle upright" % card.card_name)
	if mesh_count != _cards.size():
		failures.append("not every card has front/back plus side geometry")
	if failures.is_empty():
		print("PAPERCRAFT_SMOKE_OK cards=%d surfaces=%d leaves=%d tilt_shift=on" % [
			_cards.size(), mesh_count * 2, _leaves.size()
		])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("PAPERCRAFT_SMOKE: " + failure)
		get_tree().quit(1)

func _make_ground_texture() -> ImageTexture:
	var image := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(COLORS["ground"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261126
	for i in range(7000):
		var x := rng.randi_range(0, 511)
		var y := rng.randi_range(0, 511)
		var value := rng.randf_range(-0.035, 0.035)
		var base := COLORS["ground"]
		image.set_pixel(x, y, Color(base.r + value, base.g + value, base.b + value, 1.0))
	for i in range(900):
		var x := rng.randi_range(4, 507)
		var y := rng.randi_range(2, 509)
		var length := rng.randi_range(2, 9)
		var tint := Color("#f1dfb6") if i % 3 else Color("#8c744e")
		for j in range(length):
			var px := (x + j) % 512
			image.set_pixel(px, y, image.get_pixel(px, y).lerp(tint, 0.13))
	for i in range(24):
		var center := Vector2(rng.randf_range(0, 512), rng.randf_range(0, 512))
		for y in range(-5, 6):
			for x in range(-11, 12):
				if x * x + float(y * y) * 4.0 < 126:
					var px := int(center.x + x) % 512
					var py := int(center.y + y) % 512
					image.set_pixel(px, py, image.get_pixel(px, py).lerp(COLORS["ground_light"], 0.16))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)

func _make_tree_art(
	outline: PackedVector2Array,
	dark: Color,
	base: Color,
	light: Color,
	seed_value: int
) -> ImageTexture:
	var image := _new_art_image()
	var mask := _mask_for_outline(outline)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[_pixel_index(x, y, image.get_width())] == 0:
				continue
			var uv := Vector2(float(x) / float(image.get_width()), float(y) / float(image.get_height()))
			var color := base
			if absf(uv.x - 0.5) < 0.085 and uv.y > 0.59:
				color = Color("#64442b")
			var d1 := Vector2(uv.x - 0.31, (uv.y - 0.31) * 0.82).length()
			var d2 := Vector2(uv.x - 0.63, (uv.y - 0.39) * 0.85).length()
			var d3 := Vector2(uv.x - 0.48, (uv.y - 0.19) * 0.9).length()
			if d1 < 0.18:
				color = light
			elif d2 < 0.16:
				color = dark
			elif d3 < 0.13:
				color = light.lerp(Color("#d8c85d"), 0.25)
			image.set_pixel(x, y, color)
	_draw_leaf_clusters(image, outline, seed_value)
	_finish_art(image, outline, seed_value)
	_maybe_dump_art(image, "tree_%d" % seed_value)
	return ImageTexture.create_from_image(image)

func _make_bush_art(
	outline: PackedVector2Array,
	dark: Color,
	base: Color,
	accent: Color,
	seed_value: int
) -> ImageTexture:
	var image := _new_art_image()
	var mask := _mask_for_outline(outline)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[_pixel_index(x, y, image.get_width())] == 0:
				continue
			var uv := Vector2(float(x) / float(image.get_width()), float(y) / float(image.get_height()))
			var color := base
			if uv.y > 0.62:
				color = dark
			for i in range(5):
				var center := Vector2(0.18 + i * 0.16, 0.55 + 0.08 * sin(i * 1.7))
				if Vector2(uv.x - center.x, (uv.y - center.y) * 0.8).length() < 0.105:
					color = lighten(base, 0.10 if i % 2 == 0 else -0.08)
			image.set_pixel(x, y, color)
	for i in range(9):
		var px := int(72.0 + i * 14.0)
		var py := int(132.0 + 17.0 * sin(i * 1.4 + seed_value))
		_disc(image, Vector2(px, py), 5, accent)
		_disc(image, Vector2(px - 1, py - 2), 2, lighten(accent, 0.22))
	_finish_art(image, outline, seed_value)
	_maybe_dump_art(image, "bush_%d" % seed_value)
	return ImageTexture.create_from_image(image)

func _make_rock_art(outline: PackedVector2Array, seed_value: int) -> ImageTexture:
	var image := _new_art_image()
	var mask := _mask_for_outline(outline)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[_pixel_index(x, y, image.get_width())] == 0:
				continue
			var uv := Vector2(float(x) / float(image.get_width()), float(y) / float(image.get_height()))
			var strata := 0.07 * sin(uv.y * 42.0 + sin(uv.x * 8.0) * 2.1)
			var color := Color("#8c765e")
			color = Color(
				clampf(color.r + strata, 0.0, 1.0),
				clampf(color.g + strata, 0.0, 1.0),
				clampf(color.b + strata, 0.0, 1.0),
				1.0
			)
			if uv.y < 0.25 + 0.08 * sin(uv.x * 10.0):
				color = Color("#b39a72")
			if uv.y > 0.72:
				color = darken(color, 0.12)
			image.set_pixel(x, y, color)
	for i in range(5):
		var center := Vector2(70.0 + i * 27.0, 112.0 - 14.0 * sin(i * 1.6))
		_disc(image, center, 8, COLORS["moss_dark"])
		_disc(image, center + Vector2(-2, -2), 3, COLORS["moss_light"])
	_finish_art(image, outline, seed_value)
	_maybe_dump_art(image, "rock_%d" % seed_value)
	return ImageTexture.create_from_image(image)

func _make_lantern_art(outline: PackedVector2Array) -> ImageTexture:
	var image := _new_art_image()
	var mask := _mask_for_outline(outline)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[_pixel_index(x, y, image.get_width())] == 0:
				continue
			var uv := Vector2(float(x) / float(image.get_width()), float(y) / float(image.get_height()))
			var color := Color("#d49c32")
			if uv.x < 0.28 or uv.x > 0.72 or uv.y < 0.10 or uv.y > 0.89:
				color = Color("#563820")
			elif uv.x > 0.42 and uv.x < 0.58:
				color = Color("#f6ce64")
			elif uv.x < 0.40 and uv.y < 0.48:
				color = Color("#efbd52")
			image.set_pixel(x, y, color)
	for y in range(34, 112):
		image.set_pixel(126, y, Color("#563820"))
	_finish_art(image, outline, 149)
	_maybe_dump_art(image, "lantern")
	return ImageTexture.create_from_image(image)

func _make_arch_art(outline: PackedVector2Array) -> ImageTexture:
	var image := _new_art_image()
	var mask := _mask_for_outline(outline)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[_pixel_index(x, y, image.get_width())] == 0:
				continue
			var uv := Vector2(float(x) / float(image.get_width()), float(y) / float(image.get_height()))
			var color := COLORS["stone"]
			var row := int(uv.y * 13.0)
			if row % 3 == 0:
				color = lighten(color, 0.07)
			if uv.x < 0.18 or uv.x > 0.82:
				color = darken(color, 0.12)
			if uv.x > 0.39 and uv.x < 0.61 and uv.y > 0.42 and uv.y < 0.96:
				color = darken(COLORS["stone_dark"], 0.08)
			var brick := int(uv.x * 9.0 + row * 0.5) % 2
			if absf(fmod(uv.y * 13.0, 1.0) - 0.06) < 0.025\
				or (brick == 0 and absf(fmod(uv.x * 18.0, 1.0) - 0.5) < 0.018):
				color = darken(color, 0.22)
			image.set_pixel(x, y, color)
	for i in range(7):
		var center := Vector2(72.0 + i * 22.0, 68.0)
		_disc(image, center, 7, COLORS["moss_dark"])
		_disc(image, center + Vector2(-2, -2), 3, COLORS["moss_light"])
	_finish_art(image, outline, 71)
	_maybe_dump_art(image, "arch")
	return ImageTexture.create_from_image(image)

func _make_hero_art(outline: PackedVector2Array) -> ImageTexture:
	var image := _new_art_image()
	var mask := _mask_for_outline(outline)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[_pixel_index(x, y, image.get_width())] == 0:
				continue
			var uv := Vector2(float(x) / float(image.get_width()), float(y) / float(image.get_height()))
			var color := Color("#efe3c5")
			if uv.y < 0.31:
				color = Color("#d9b17d")
			elif uv.y < 0.61 and uv.x > 0.35 and uv.x < 0.65:
				color = COLORS["blue"]
			elif uv.y < 0.82:
				color = COLORS["crimson"]
			else:
				color = Color("#533c31")
			if uv.y > 0.30 and uv.y < 0.37:
				color = COLORS["gold"]
			if uv.y < 0.15 and uv.x > 0.44 and uv.x < 0.56:
				color = Color("#49372b")
			if uv.y > 0.34 and uv.y < 0.44 and absf(uv.x - 0.5) < 0.035:
				color = COLORS["cream"]
			image.set_pixel(x, y, color)
	_disc(image, Vector2(128, 58), 8, Color("#32251f"))
	_disc(image, Vector2(119, 60), 3, Color("#1f1713"))
	_disc(image, Vector2(137, 60), 3, Color("#1f1713"))
	_finish_art(image, outline, 83)
	_maybe_dump_art(image, "hero")
	return ImageTexture.create_from_image(image)

func _make_die_art(outline: PackedVector2Array) -> ImageTexture:
	var image := _new_art_image()
	var mask := _mask_for_outline(outline)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if mask[_pixel_index(x, y, image.get_width())] == 0:
				continue
			var uv := Vector2(float(x) / float(image.get_width()), float(y) / float(image.get_height()))
			var color := Color("#c89049")
			if uv.y > 0.82:
				color = darken(color, 0.20)
			if uv.x > 0.37 and uv.y < 0.13:
				color = lighten(color, 0.12)
			image.set_pixel(x, y, color)
	for pos in [
		Vector2(0.30, 0.30), Vector2(0.70, 0.30), Vector2(0.50, 0.50),
		Vector2(0.30, 0.70), Vector2(0.70, 0.70)
	]:
		_disc(image, Vector2(pos.x * 256.0, pos.y * 384.0), 9, COLORS["ink"])
		_disc(image, Vector2(pos.x * 256.0 - 2, pos.y * 384.0 - 3), 3, COLORS["cream"])
	_finish_art(image, outline, 97)
	_maybe_dump_art(image, "die")
	return ImageTexture.create_from_image(image)

func _make_leaf_art(color: Color, seed_value: int) -> ImageTexture:
	var image := Image.create(64, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var outline := PackedVector2Array([
		Vector2(0.04, 0.50), Vector2(0.20, 0.18), Vector2(0.48, 0.08),
		Vector2(0.78, 0.17), Vector2(0.96, 0.50), Vector2(0.77, 0.81),
		Vector2(0.48, 0.93), Vector2(0.21, 0.82)
	])
	for y in range(32):
		for x in range(64):
			if not _point_in_polygon(Vector2((x + 0.5) / 64.0, (y + 0.5) / 32.0), outline):
				continue
			var pixel := color
			var edge := x < 3 or x > 60 or y < 2 or y > 29
			if edge:
				pixel = COLORS["ink"]
			elif x < 15 and y < 13:
				pixel = lighten(color, 0.24)
			image.set_pixel(x, y, pixel)
	for i in range(13, 52):
		image.set_pixel(i, 16, darken(color, 0.28))
	image.generate_mipmaps()
	_maybe_dump_art(image, "leaf_%d" % seed_value)
	return ImageTexture.create_from_image(image)

func _new_art_image() -> Image:
	var image := Image.create(256, 384, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image

func _mask_for_outline(outline: PackedVector2Array) -> PackedByteArray:
	var mask := PackedByteArray()
	mask.resize(256 * 384)
	for y in range(384):
		var v := (float(y) + 0.5) / 384.0
		for x in range(256):
			var u := (float(x) + 0.5) / 256.0
			if _point_in_polygon(Vector2(u, v), outline):
				mask[_pixel_index(x, y, 256)] = 1
	return mask

func _finish_art(image: Image, outline: PackedVector2Array, seed_value: int) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var mask := _mask_for_outline(outline)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for y in range(height):
		for x in range(width):
			var index := _pixel_index(x, y, width)
			if mask[index] == 0:
				continue
			var color := image.get_pixel(x, y)
			var grain := rng.randf_range(-0.022, 0.022)
			color = Color(
				clampf(color.r + grain, 0.0, 1.0),
				clampf(color.g + grain, 0.0, 1.0),
				clampf(color.b + grain, 0.0, 1.0),
				1.0
			)
			var dark_edge := false
			var lit_edge := false
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0:
						continue
					var nx := x + dx
					var ny := y + dy
					if nx < 0 or nx >= width or ny < 0 or ny >= height\
						or mask[_pixel_index(nx, ny, width)] == 0:
						dark_edge = true
			for check in [Vector2i(-2, -1), Vector2i(-1, -2), Vector2i(-2, -3)]:
				var nx: int = x + int(check.x)
				var ny: int = y + int(check.y)
				if nx < 0 or nx >= width or ny < 0 or ny >= height\
					or mask[_pixel_index(nx, ny, width)] == 0:
					lit_edge = true
			if dark_edge:
				color = COLORS["ink"]
			elif lit_edge:
				color = color.lerp(COLORS["cream"], 0.42)
			image.set_pixel(x, y, color)
	image.generate_mipmaps()

func _draw_leaf_clusters(image: Image, outline: PackedVector2Array, seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(28):
		var center := Vector2(
			rng.randf_range(0.18, 0.82) * 256.0,
			rng.randf_range(0.08, 0.56) * 384.0
		)
		if not _point_in_polygon(center / Vector2(256.0, 384.0), outline):
			continue
		var radius := rng.randf_range(4.0, 8.0)
		_disc(image, center, radius, COLORS["moss_light"] if i % 2 else COLORS["moss_dark"])
		_disc(image, center + Vector2(-2.0, -2.0), radius * 0.35, COLORS["cream"])

func _disc(image: Image, center: Vector2, radius: float, color: Color) -> void:
	var min_x := maxi(0, int(center.x - radius))
	var max_x := mini(image.get_width() - 1, int(center.x + radius))
	var min_y := maxi(0, int(center.y - radius))
	var max_y := mini(image.get_height() - 1, int(center.y + radius))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if Vector2(x + 0.5, y + 0.5).distance_to(center) <= radius:
				image.set_pixel(x, y, color)

func _point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	var inside := false
	var j := polygon.size() - 1
	for i in range(polygon.size()):
		var a := polygon[i]
		var b := polygon[j]
		if ((a.y > point.y) != (b.y > point.y))\
			and point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x:
			inside = not inside
		j = i
	return inside

func _pixel_index(x: int, y: int, width: int) -> int:
	return y * width + x

func _maybe_dump_art(image: Image, name_value: String) -> void:
	if _dump_art:
		var error := image.save_png("/tmp/papercraft_art_%s.png" % name_value)
		if error != OK:
			push_warning("Could not dump generated art: %s" % name_value)

func _tree_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.43, 1.00), Vector2(0.44, 0.62), Vector2(0.29, 0.64),
		Vector2(0.20, 0.55), Vector2(0.27, 0.46), Vector2(0.14, 0.34),
		Vector2(0.24, 0.26), Vector2(0.23, 0.12), Vector2(0.39, 0.15),
		Vector2(0.44, 0.03), Vector2(0.54, 0.09), Vector2(0.63, 0.01),
		Vector2(0.69, 0.14), Vector2(0.83, 0.10), Vector2(0.79, 0.25),
		Vector2(0.91, 0.33), Vector2(0.79, 0.44), Vector2(0.87, 0.56),
		Vector2(0.70, 0.63), Vector2(0.57, 0.62), Vector2(0.56, 1.00),
		Vector2(0.50, 0.94), Vector2(0.47, 0.94)
	])

func _bush_outline() -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(15):
		var angle := PI + PI * float(i) / 14.0
		var radius := 0.39 + 0.05 * sin(float(i) * 2.4)
		points.append(Vector2(0.5 + cos(angle) * radius, 0.88 + sin(angle) * radius * 0.80))
	points.append(Vector2(0.87, 0.96))
	points.append(Vector2(0.13, 0.96))
	return points

func _arch_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.10, 1.00), Vector2(0.10, 0.34), Vector2(0.18, 0.29),
		Vector2(0.18, 0.14), Vector2(0.27, 0.14), Vector2(0.27, 0.28),
		Vector2(0.36, 0.21), Vector2(0.50, 0.12), Vector2(0.64, 0.21),
		Vector2(0.73, 0.28), Vector2(0.73, 0.14), Vector2(0.82, 0.14),
		Vector2(0.82, 0.29), Vector2(0.90, 0.34), Vector2(0.90, 1.00)
	])

func _hero_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.37, 1.00), Vector2(0.38, 0.70), Vector2(0.24, 0.64),
		Vector2(0.20, 0.44), Vector2(0.32, 0.39), Vector2(0.33, 0.25),
		Vector2(0.42, 0.19), Vector2(0.43, 0.08), Vector2(0.50, 0.03),
		Vector2(0.57, 0.08), Vector2(0.58, 0.19), Vector2(0.69, 0.25),
		Vector2(0.71, 0.39), Vector2(0.80, 0.44), Vector2(0.76, 0.64),
		Vector2(0.62, 0.70), Vector2(0.63, 1.00), Vector2(0.50, 0.93),
		Vector2(0.48, 0.93)
	])

func _rock_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.08, 0.91), Vector2(0.14, 0.61), Vector2(0.31, 0.42),
		Vector2(0.38, 0.18), Vector2(0.57, 0.10), Vector2(0.72, 0.28),
		Vector2(0.88, 0.39), Vector2(0.94, 0.70), Vector2(0.83, 0.91)
	])

func _lantern_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.31, 0.90), Vector2(0.30, 0.28), Vector2(0.40, 0.14),
		Vector2(0.50, 0.08), Vector2(0.60, 0.14), Vector2(0.70, 0.28),
		Vector2(0.69, 0.90), Vector2(0.60, 0.96), Vector2(0.40, 0.96)
	])

func _rounded_card_outline() -> PackedVector2Array:
	var points := PackedVector2Array()
	var radius := 0.08
	var corners := [
		[Vector2(0.15, 0.12), -PI * 0.5, PI * 0.5],
		[Vector2(0.85, 0.12), 0.0, PI * 0.5],
		[Vector2(0.85, 0.88), PI * 0.5, PI * 0.5],
		[Vector2(0.15, 0.88), PI, PI * 0.5],
	]
	for corner in corners:
		for i in range(4):
			var angle := float(corner[1]) + float(corner[2]) * float(i) / 3.0
			points.append(Vector2(corner[0]) + Vector2(cos(angle), sin(angle)) * radius)
	return points

func _stable_seed(value: String) -> int:
	var total := 17
	for i in range(value.length()):
		total = (total * 31 + value.unicode_at(i)) % 2147483647
	return total

func lighten(color: Color, amount: float) -> Color:
	return color.lerp(Color.WHITE, amount)

func darken(color: Color, amount: float) -> Color:
	return color.lerp(Color.BLACK, amount)
