class_name PaperCard
extends Node3D

signal card_clicked(card: PaperCard)

var card_name := ""
var card_size := Vector2.ONE
var outline := PackedVector2Array()
var base_yaw := 0.0

var _pivot: Node3D
var _mesh: MeshInstance3D
var _surface: ShaderMaterial
var _rng := RandomNumberGenerator.new()
var _settled_time := -1.0
var _pop_tween: Tween

func setup(
	value_name: String,
	value_outline: PackedVector2Array,
	value_size: Vector2,
	artwork: Texture2D,
	seed_value: int,
	yaw_degrees: float = 0.0
) -> void:
	card_name = value_name
	outline = value_outline
	card_size = value_size
	base_yaw = deg_to_rad(yaw_degrees)
	_rng.seed = seed_value
	add_to_group("paper_cards")

	_pivot = Node3D.new()
	_pivot.name = "HingePivot"
	add_child(_pivot)

	var built_mesh := _build_slab(value_outline, value_size, maxf(0.024, value_size.y * 0.024))
	_mesh = MeshInstance3D.new()
	_mesh.name = "PrintedCard"
	_mesh.mesh = built_mesh
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	_pivot.add_child(_mesh)

	_surface = ShaderMaterial.new()
	_surface.shader = load("res://paper_surface.gdshader")
	_surface.set_shader_parameter("artwork", artwork)
	_surface.set_shader_parameter("seed_value", float(seed_value % 997) * 0.013)
	_surface.set_shader_parameter("leak_color", Color("#734421"))
	_mesh.set_surface_override_material(0, _surface)

	var side_material := StandardMaterial3D.new()
	side_material.albedo_color = Color("#5d3c25")
	side_material.roughness = 1.0
	side_material.metallic = 0.0
	side_material.metallic_specular = 0.0
	side_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mesh.set_surface_override_material(1, side_material)

	var body := StaticBody3D.new()
	body.name = "ClickBody"
	body.input_ray_pickable = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(value_size.x * 0.82, value_size.y * 0.92, 0.16)
	shape.shape = box
	shape.position.y = value_size.y * 0.5
	body.add_child(shape)
	body.input_event.connect(_on_input_event)
	_pivot.add_child(body)

	rotation.y = base_yaw
	_pivot.rotation_degrees.x = -90.0

func pop_up(delay: float = 0.0) -> void:
	if _pop_tween and _pop_tween.is_valid():
		_pop_tween.kill()
	_pivot.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	_settled_time = -1.0
	_pop_tween = create_tween()
	_pop_tween.tween_interval(delay)
	_pop_tween.tween_property(_pivot, "rotation_degrees:x", -2.0, 0.43)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pop_tween.tween_property(_pivot, "rotation_degrees:x", 0.8, 0.13)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pop_tween.tween_property(_pivot, "rotation_degrees:x", 0.0, 0.16)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_pop_tween.finished.connect(func() -> void: _settled_time = 0.0)

func hop() -> void:
	if not is_instance_valid(_mesh):
		return
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_mesh, "position:z", 0.18, 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(_pivot, "rotation:y", 0.16, 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.chain().set_parallel(true)
	tw.tween_property(_mesh, "position:z", 0.0, 0.24)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_pivot, "rotation:y", 0.0, 0.22)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if _surface:
		var flash := create_tween()
		flash.tween_method(
			func(value: float) -> void: _surface.set_shader_parameter("flash", value),
			0.32, 0.0, 0.18
		)

func _process(delta: float) -> void:
	if _settled_time < 0.0 or not is_instance_valid(_pivot):
		return
	if _pop_tween and _pop_tween.is_running():
		return
	_settled_time += delta
	var phase := float(_rng.randi_range(0, 1000)) * 0.01 + _settled_time
	_pivot.rotation.y = sin(phase * 1.17) * 0.006
	_mesh.position.z = 0.0

func _on_input_event(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_clicked.emit(self)

func _build_slab(points: PackedVector2Array, size: Vector2, thickness: float) -> ArrayMesh:
	var triangles := Geometry2D.triangulate_polygon(points)
	if triangles.is_empty():
		push_error("Outline failed to triangulate for card")
		return ArrayMesh.new()

	var front_vertices := PackedVector3Array()
	var front_normals := PackedVector3Array()
	var front_uvs := PackedVector2Array()
	var count := points.size()
	for point in points:
		front_vertices.append(_to_local(point, size, thickness * 0.5))
		front_normals.append(Vector3.BACK)
		front_uvs.append(Vector2(point.x, point.y))
	for point in points:
		front_vertices.append(_to_local(point, size, -thickness * 0.5))
		front_normals.append(Vector3.FORWARD)
		front_uvs.append(Vector2(1.0 - point.x, point.y))

	var front_indices := PackedInt32Array()
	for i in range(0, triangles.size(), 3):
		front_indices.append_array([
			triangles[i], triangles[i + 1], triangles[i + 2],
			triangles[i + 2] + count, triangles[i + 1] + count, triangles[i] + count
		])

	var caps := []
	caps.resize(Mesh.ARRAY_MAX)
	caps[Mesh.ARRAY_VERTEX] = front_vertices
	caps[Mesh.ARRAY_NORMAL] = front_normals
	caps[Mesh.ARRAY_TEX_UV] = front_uvs
	caps[Mesh.ARRAY_INDEX] = front_indices

	var side_vertices := PackedVector3Array()
	var side_normals := PackedVector3Array()
	var side_uvs := PackedVector2Array()
	var side_indices := PackedInt32Array()
	for i in range(count):
		var a := points[i]
		var b := points[(i + 1) % count]
		var a0 := _to_local(a, size, thickness * 0.5)
		var b0 := _to_local(b, size, thickness * 0.5)
		var a1 := _to_local(a, size, -thickness * 0.5)
		var b1 := _to_local(b, size, -thickness * 0.5)
		var base_index := side_vertices.size()
		side_vertices.append_array([a0, b0, b1, a1])
		var edge := Vector2(b.x - a.x, -(b.y - a.y)).normalized()
		var normal := Vector3(edge.x, edge.y, 0.0).normalized()
		side_normals.append_array([normal, normal, normal, normal])
		side_uvs.append_array([
			Vector2(0.0, 0.0), Vector2(1.0, 0.0),
			Vector2(1.0, 1.0), Vector2(0.0, 1.0)
		])
		side_indices.append_array([
			base_index, base_index + 1, base_index + 2,
			base_index, base_index + 2, base_index + 3
		])

	var sides := []
	sides.resize(Mesh.ARRAY_MAX)
	sides[Mesh.ARRAY_VERTEX] = side_vertices
	sides[Mesh.ARRAY_NORMAL] = side_normals
	sides[Mesh.ARRAY_TEX_UV] = side_uvs
	sides[Mesh.ARRAY_INDEX] = side_indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, caps)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sides)
	return mesh

func _to_local(point: Vector2, size: Vector2, z: float) -> Vector3:
	return Vector3((point.x - 0.5) * size.x, (1.0 - point.y) * size.y, z)
