@tool
class_name ValleyPath
extends Path3D
## El camino del valle. Es una curva: mueve sus puntos en el editor (o añade más) y todo lo
## demás se rehace solo a lo largo de ella: suelo, sendero, acantilados, árboles, matojos y
## las paredes invisibles. Puede ir en cualquier dirección y serpentear lo que quieras.
##
## Los bordes que quedan entre la cámara y el cocinero salen bajos (rocas y arbustos) para que
## nunca le tapen; los del fondo, altos (acantilados).
##
## Lo generado NO se guarda en la escena: se rehace al abrirla y al jugar, siempre igual
## (misma `decor_seed` = mismo valle). Para cambiar el valle, cambia la curva o estos valores.
##
## Consejo: deja las curvas abiertas (radio mayor que el ancho del camino); si giras muy
## cerrado, los bordes de dentro se pisan.
##
## Además mide: cuánto has avanzado (`offset_of`), qué punto hay X metros más allá (`point_at`).

@export_tool_button("Rehacer ahora", "Reload") var rebuild_action: Callable = rebuild

@export_group("Forma")
## Ancho por el que se puede andar (m).
@export var width: float = 11.0:
	set(value):
		width = maxf(value, 2.0)
		_queue_rebuild()
## Ancho del sendero de tierra del centro (m). 0 = sin sendero.
@export var trail_width: float = 4.0:
	set(value):
		trail_width = maxf(value, 0.0)
		_queue_rebuild()
## Ondulación de los bordes (m), para que no parezca una carretera.
@export var edge_wobble: float = 0.6:
	set(value):
		edge_wobble = value
		_queue_rebuild()
## Suaviza la curva sola: solo tienes que mover puntos, sin tocar los tiradores.
@export var auto_smooth: bool = true:
	set(value):
		auto_smooth = value
		_queue_rebuild()
## Lo redondas que salen las curvas con auto_smooth.
@export_range(0.0, 0.5) var smoothness: float = 0.3:
	set(value):
		smoothness = value
		_queue_rebuild()
## Cada cuántos metros se coloca un trozo de borde. Más bajo = más detalle (y más coste).
@export_range(0.5, 3.0) var step: float = 1.0:
	set(value):
		step = value
		_queue_rebuild()

@export_group("Bordes")
## Material de las rocas de los bordes.
@export var cliff_material: Material:
	set(value):
		cliff_material = value
		_queue_rebuild()
## Altura de la meseta del fondo (m): el camino va encajonado y arriba está el bosque.
## Hacia el lado de la cámara baja poco a poco hasta el suelo.
@export var plateau_height: float = 2.6:
	set(value):
		plateau_height = value
		_queue_rebuild()
## Lo que sobresalen las rocas del borde por encima/debajo de la meseta (m, mín y máx).
@export var cliff_jitter: Vector2 = Vector2(-0.25, 0.6):
	set(value):
		cliff_jitter = value
		_queue_rebuild()
## Ancho de la meseta a cada lado (m).
@export var plateau_width: float = 14.0:
	set(value):
		plateau_width = value
		_queue_rebuild()
## Altura de los bordes del lado de la cámara (m). Bajos para no tapar.
@export var near_height: Vector2 = Vector2(0.25, 0.6):
	set(value):
		near_height = value
		_queue_rebuild()
## Hueco entre el límite por el que se anda y la roca del fondo (m). Los sprites miran a la
## cámara y se inclinan hacia atrás: sin este hueco, la cabeza se mete en la pared.
@export var cliff_gap: float = 0.9:
	set(value):
		cliff_gap = value
		_queue_rebuild()
## Grosor de la pared de roca (m).
@export var cliff_depth: float = 1.8:
	set(value):
		cliff_depth = value
		_queue_rebuild()
## Altura de las paredes invisibles (m).
@export var wall_height: float = 3.0
## En el editor, espera tras el último cambio antes de rehacer (s).
@export var editor_rebuild_delay: float = 0.35

@export_group("Suelo")
@export var ground_material: Material:
	set(value):
		ground_material = value
		_queue_rebuild()
@export var trail_material: Material:
	set(value):
		trail_material = value
		_queue_rebuild()
## Suelo extra alrededor del camino (m), donde van los árboles.
@export var ground_margin: float = 16.0:
	set(value):
		ground_margin = value
		_queue_rebuild()

@export_group("Decorado")
@export var tree_scene: PackedScene:
	set(value):
		tree_scene = value
		_queue_rebuild()
@export var bush_scene: PackedScene:
	set(value):
		bush_scene = value
		_queue_rebuild()
@export var rock_scene: PackedScene:
	set(value):
		rock_scene = value
		_queue_rebuild()
@export var grass_scene: PackedScene:
	set(value):
		grass_scene = value
		_queue_rebuild()
## Metros entre árboles a lo largo del borde.
@export var tree_spacing: float = 1.6:
	set(value):
		tree_spacing = maxf(value, 0.5)
		_queue_rebuild()
## Hasta dónde llega el bosque desde el borde (m).
@export var forest_depth: float = 9.0:
	set(value):
		forest_depth = value
		_queue_rebuild()
## En el lado de la cámara los árboles empiezan más lejos (m), para no tapar.
@export var near_tree_clearance: float = 6.5:
	set(value):
		near_tree_clearance = value
		_queue_rebuild()
## Matojos de hierba por metro de camino.
@export var grass_per_meter: float = 0.7:
	set(value):
		grass_per_meter = value
		_queue_rebuild()
## Rocas sueltas por metro de camino.
@export var rocks_per_meter: float = 0.1:
	set(value):
		rocks_per_meter = value
		_queue_rebuild()
## Luces por el camino (braseros, farolillos...). Vacío = ninguna.
@export var lamp_scene: PackedScene:
	set(value):
		lamp_scene = value
		_queue_rebuild()
## Metros entre luces (van alternando de lado).
@export var lamp_spacing: float = 30.0:
	set(value):
		lamp_spacing = maxf(value, 5.0)
		_queue_rebuild()
## Semilla del azar: cámbiala para otra colocación del decorado.
@export var decor_seed: int = 1:
	set(value):
		decor_seed = value
		_queue_rebuild()

var _rebuild_queued: bool = false
var _rebuild_token: int = 0
var _smoothing: bool = false
var _generated: Node3D


func _ready() -> void:
	curve_changed.connect(_on_curve_changed)
	rebuild()


# --- Medir ---------------------------------------------------------------------

## Largo total del camino (m).
func get_length() -> float:
	return curve.get_baked_length() if curve else 0.0


## Metros recorridos a lo largo del camino hasta el punto más cercano a `world_position`.
func offset_of(world_position: Vector3) -> float:
	if curve == null:
		return 0.0
	return curve.get_closest_offset(to_local(world_position))


## Punto del suelo a `offset` metros del inicio, desplazado `lateral` metros a un lado
## (positivo = a la izquierda mirando hacia delante).
func point_at(offset: float, lateral: float = 0.0) -> Vector3:
	var local := _sample(offset) + _side(offset) * lateral
	var p := to_global(local)
	p.y = 0.0
	return p


## Dirección hacia delante del camino en `offset` (en el suelo, global).
func forward_at(offset: float) -> Vector3:
	var t := global_basis * _tangent(offset)
	t.y = 0.0
	return t.normalized()


## Medio ancho jugable en `offset` (con la ondulación).
func half_width_at(offset: float) -> float:
	return width * 0.5 + _wobble(offset, 0)


# --- Construir -----------------------------------------------------------------

func rebuild() -> void:
	_rebuild_queued = false
	if not is_inside_tree():
		return
	if _generated:
		_generated.free()
	_generated = Node3D.new()
	_generated.name = "Generated"
	add_child(_generated, false, Node.INTERNAL_MODE_BACK)
	if curve == null or curve.point_count < 2:
		return
	if auto_smooth:
		_smooth_curve()
	var rng := RandomNumberGenerator.new()
	rng.seed = decor_seed
	var length := get_length()
	var samples := _build_samples(length)
	_build_ground(samples)
	_build_plateau(samples)
	if trail_width > 0.0:
		_build_trail(samples)
	_build_cliffs(samples, rng)
	_build_walls(samples, length)
	_build_decor(length, rng)
	_build_lamps(length)


## Pide rehacer. En el editor espera a que dejes de tocar (arrastrar un punto pide
## muchos cambios seguidos y rehacer en cada uno va lento, sobre todo en la tablet).
func _queue_rebuild() -> void:
	if not is_inside_tree():
		return
	_rebuild_token += 1
	var token := _rebuild_token
	if Engine.is_editor_hint():
		await get_tree().create_timer(editor_rebuild_delay).timeout
		if token == _rebuild_token and is_inside_tree():
			rebuild()
	elif not _rebuild_queued:
		_rebuild_queued = true
		rebuild.call_deferred()


func _on_curve_changed() -> void:
	if not _smoothing:
		_queue_rebuild()


## Pone los tiradores de cada punto según sus vecinos (Catmull-Rom) y el camino a ras de suelo.
func _smooth_curve() -> void:
	_smoothing = true
	var n := curve.point_count
	for i in n:
		var p := curve.get_point_position(i)
		if p.y != 0.0:
			curve.set_point_position(i, Vector3(p.x, 0.0, p.z))
	for i in n:
		var prev := curve.get_point_position(maxi(i - 1, 0))
		var next := curve.get_point_position(mini(i + 1, n - 1))
		var handle := (next - prev) * smoothness
		if i == 0 or i == n - 1:
			handle = Vector3.ZERO
		# Solo si cambian (si no, la curva avisa de un cambio y se rehace todo otra vez).
		if not curve.get_point_out(i).is_equal_approx(handle):
			curve.set_point_in(i, -handle)
			curve.set_point_out(i, handle)
	_smoothing = false


## Puntos cada `step` m: posición, lado izquierdo y medio ancho de cada borde.
func _build_samples(length: float) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var count := maxi(ceili(length / step), 1)
	for i in count + 1:
		var off := length * i / count
		out.append({
			offset = off,
			pos = _sample(off),
			side = _side(off),
			half = [width * 0.5 + _wobble(off, 0), width * 0.5 + _wobble(off, 1)],
		})
	return out


func _build_ground(samples: Array[Dictionary]) -> void:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for s in samples:
		var p: Vector3 = s.pos
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.z))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.z))
	var margin := width * 0.5 + ground_margin
	var plane := PlaneMesh.new()
	plane.size = hi - lo + Vector2.ONE * margin * 2.0
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	ground.mesh = plane
	ground.material_override = ground_material
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ground.position = Vector3((lo.x + hi.x) * 0.5, 0.0, (lo.y + hi.y) * 0.5)
	_generated.add_child(ground)


func _build_trail(samples: Array[Dictionary]) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	for i in samples.size():
		var s: Dictionary = samples[i]
		var half := trail_width * 0.5 * (1.0 + 0.25 * sin(s.offset * 0.45 + decor_seed))
		var l: Vector3 = s.pos + s.side * half + Vector3(0, 0.01, 0)
		var r: Vector3 = s.pos - s.side * half + Vector3(0, 0.01, 0)
		if i > 0:
			for v in [prev_l, l, prev_r, prev_r, l, r]:
				st.add_vertex(v)
		prev_l = l
		prev_r = r
	var trail := MeshInstance3D.new()
	trail.name = "Trail"
	trail.mesh = st.commit()
	trail.material_override = trail_material
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_generated.add_child(trail)


## Rocas de los bordes: una por muestra y lado. Altas al fondo, bajas hacia la cámara.
func _build_cliffs(samples: Array[Dictionary], rng: RandomNumberGenerator) -> void:
	var transforms: Array[Transform3D] = []
	var colors: Array[Color] = []
	for s in samples:
		for side_index in 2:
			var sgn := 1.0 if side_index == 0 else -1.0
			var outward: Vector3 = s.side * sgn
			var near := _nearness(outward)
			var far_h := plateau_height + rng.randf_range(cliff_jitter.x, cliff_jitter.y)
			var h := lerpf(far_h, rng.randf_range(near_height.x, near_height.y), near)
			var depth := cliff_depth * rng.randf_range(0.8, 1.2)
			var along := step * rng.randf_range(1.2, 1.6)
			var gap := cliff_gap * (1.0 - near)
			var center: Vector3 = s.pos + outward * (s.half[side_index] + gap + depth * 0.5)
			var yaw := atan2(outward.x, outward.z) + rng.randf_range(-0.25, 0.25)
			var block_basis := Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3(along, h, depth))
			transforms.append(Transform3D(block_basis, center + Vector3(0, h * 0.5, 0)))
			var tone := rng.randf_range(0.82, 1.08)
			colors.append(Color(tone, tone, tone * rng.randf_range(0.97, 1.05)))
			# Una roca extra más baja delante de los acantilados altos, para romper la línea.
			if near < 0.4 and rng.randf() < 0.35:
				var h2 := h * rng.randf_range(0.3, 0.55)
				var c2: Vector3 = s.pos + outward * (s.half[side_index] + gap + 0.35)
				var b2 := Basis(Vector3.UP, yaw + rng.randf_range(-0.6, 0.6)) * Basis.from_scale(Vector3(along * 0.6, h2, 0.9))
				transforms.append(Transform3D(b2, c2 + Vector3(0, h2 * 0.5, 0)))
				colors.append(Color(tone * 0.9, tone * 0.9, tone * 0.95))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = BoxMesh.new()
	mm.instance_count = transforms.size()
	for i in transforms.size():
		mm.set_instance_transform(i, transforms[i])
		mm.set_instance_color(i, colors[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.name = "Cliffs"
	mmi.multimesh = mm
	mmi.material_override = cliff_material
	_generated.add_child(mmi)


## Paredes invisibles por los dos bordes y en los dos extremos.
func _build_walls(samples: Array[Dictionary], length: float) -> void:
	var body := StaticBody3D.new()
	body.name = "Walls"
	body.collision_layer = 1
	body.collision_mask = 0
	_generated.add_child(body)
	for i in range(1, samples.size()):
		var a: Dictionary = samples[i - 1]
		var b: Dictionary = samples[i]
		for side_index in 2:
			var sgn := 1.0 if side_index == 0 else -1.0
			var pa: Vector3 = a.pos + a.side * sgn * (a.half[side_index] + 0.5)
			var pb: Vector3 = b.pos + b.side * sgn * (b.half[side_index] + 0.5)
			_add_wall(body, pa, pb, 1.0)
	for end in [0.0, length]:
		var forward := _tangent(end) * (-1.0 if end == 0.0 else 1.0)
		var c := _sample(end) + forward * 0.5
		var side := _side(end) * (width * 0.5 + 1.5)
		_add_wall(body, c + side, c - side, 1.0)


func _add_wall(body: StaticBody3D, a: Vector3, b: Vector3, thickness: float) -> void:
	var seg := b - a
	var length := seg.length() + 0.3
	if length < 0.01:
		return
	var box := BoxShape3D.new()
	box.size = Vector3(length, wall_height, thickness)
	var shape := CollisionShape3D.new()
	shape.shape = box
	var yaw := atan2(-seg.z, seg.x)
	shape.transform = Transform3D(Basis(Vector3.UP, yaw), (a + b) * 0.5 + Vector3(0, wall_height * 0.5, 0))
	body.add_child(shape)


func _build_decor(length: float, rng: RandomNumberGenerator) -> void:
	var decor := Node3D.new()
	decor.name = "Decor"
	_generated.add_child(decor)
	# Bosque a los dos lados.
	if tree_scene:
		var off := 0.0
		while off < length:
			for side_index in 2:
				var sgn := 1.0 if side_index == 0 else -1.0
				var outward := _side(off) * sgn
				var near := _nearness(outward)
				# Al fondo, encima de la meseta (asomando por el borde); hacia la cámara, lejos.
				var start := width * 0.5 + cliff_depth * 0.6
				if near > 0.3:
					start = maxf(start, width * 0.5 + near_tree_clearance)
				var dist := rng.randf_range(start, start + forest_depth)
				var p := _sample(off + rng.randf_range(-0.6, 0.6)) + outward * dist
				if _clear_of_path(p, start - 0.5):
					var y := _ledge_height(outward) if dist < width * 0.5 + plateau_width else 0.0
					var t := _place(decor, tree_scene, p, y)
					t.scale = Vector3.ONE * rng.randf_range(0.85, 1.35)
				# Arbustos tapando la base de los bordes bajos.
				if bush_scene and near > 0.5 and rng.randf() < 0.45:
					var bp := _sample(off) + outward * (width * 0.5 + rng.randf_range(0.6, 2.2))
					if _clear_of_path(bp, width * 0.5):
						_place(decor, bush_scene, bp).scale = Vector3.ONE * rng.randf_range(0.8, 1.2)
			off += tree_spacing * rng.randf_range(0.7, 1.3)
	# Hierba y rocas sueltas dentro del camino.
	for spec in [[grass_scene, grass_per_meter, 0.6], [rock_scene, rocks_per_meter, 0.8]]:
		var scene: PackedScene = spec[0]
		if scene == null:
			continue
		var count := int(length * spec[1])
		for i in count:
			var off := rng.randf() * length
			var margin: float = spec[2]
			var lat := rng.randf_range(-1.0, 1.0) * (half_width_at(off) - margin)
			# Las rocas mejor hacia los bordes, que el centro quede despejado.
			if scene == rock_scene:
				lat = signf(lat if lat != 0.0 else 1.0) * rng.randf_range(width * 0.3, width * 0.5 - 0.6)
			_place(decor, scene, _sample(off) + _side(off) * lat)


func _place(parent: Node3D, scene: PackedScene, local_position: Vector3, y: float = 0.0) -> Node3D:
	var n := scene.instantiate() as Node3D
	n.position = Vector3(local_position.x, y, local_position.z)
	parent.add_child(n)
	return n


## Altura del terreno de fuera en un borde que mira hacia `outward`:
## la meseta al fondo, el suelo hacia la cámara.
func _ledge_height(outward: Vector3) -> float:
	return plateau_height * (1.0 - _nearness(outward))


## La meseta: una franja elevada a cada lado, a la altura de los acantilados.
func _build_plateau(samples: Array[Dictionary]) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for side_index in 2:
		var sgn := 1.0 if side_index == 0 else -1.0
		var prev_in := Vector3.ZERO
		var prev_out := Vector3.ZERO
		for i in samples.size():
			var s: Dictionary = samples[i]
			var outward: Vector3 = s.side * sgn
			var y := _ledge_height(outward) - 0.05
			var inner: Vector3 = s.pos + outward * (s.half[side_index] + cliff_gap * (1.0 - _nearness(outward)) + 0.3) + Vector3(0, y, 0)
			var outer: Vector3 = s.pos + outward * (s.half[side_index] + plateau_width) + Vector3(0, y, 0)
			if i > 0:
				# El orden de los vértices depende del lado para que la cara mire arriba.
				if side_index == 0:
					for v in [prev_in, prev_out, inner, inner, prev_out, outer]:
						st.add_vertex(v)
				else:
					for v in [prev_in, inner, prev_out, prev_out, inner, outer]:
						st.add_vertex(v)
			prev_in = inner
			prev_out = outer
	var plateau := MeshInstance3D.new()
	plateau.name = "Plateau"
	plateau.mesh = st.commit()
	plateau.material_override = ground_material
	_generated.add_child(plateau)


## Luces cada `lamp_spacing` m, alternando de lado, pegadas al borde.
func _build_lamps(length: float) -> void:
	if lamp_scene == null:
		return
	var lamps := Node3D.new()
	lamps.name = "Lamps"
	_generated.add_child(lamps)
	var off := lamp_spacing * 0.5
	var side := 1.0
	while off < length - 2.0:
		var lat := (half_width_at(off) - 0.9) * side
		_place(lamps, lamp_scene, _sample(off) + _side(off) * lat)
		side = -side
		off += lamp_spacing


## True si `p` está a más de `min_distance` de cualquier parte del camino
## (evita poner árboles en mitad de otro tramo cuando el camino pasa cerca de sí mismo).
func _clear_of_path(p: Vector3, min_distance: float) -> bool:
	var closest := curve.get_closest_point(p)
	return Vector2(closest.x - p.x, closest.z - p.z).length() >= min_distance


## 0 = borde del fondo (lejos de la cámara), 1 = borde del lado de la cámara.
## La cámara mira hacia -Z, así que un borde cuya cara de fuera apunta a +Z está delante.
func _nearness(outward: Vector3) -> float:
	var n := (global_basis * outward).normalized()
	return smoothstep(-0.15, 0.55, n.z)


func _sample(offset: float) -> Vector3:
	var p := curve.sample_baked(clampf(offset, 0.0, get_length()))
	p.y = 0.0
	return p


func _tangent(offset: float) -> Vector3:
	var length := get_length()
	var a := _sample(clampf(offset - 0.5, 0.0, length))
	var b := _sample(clampf(offset + 0.5, 0.0, length))
	var t := b - a
	t.y = 0.0
	return t.normalized() if t.length() > 0.001 else Vector3.FORWARD


## Lado izquierdo (mirando hacia delante), en el suelo.
func _side(offset: float) -> Vector3:
	var t := _tangent(offset)
	return Vector3(t.z, 0.0, -t.x)


func _wobble(offset: float, side_index: int) -> float:
	var k := float(decor_seed * 13 + side_index * 7)
	return edge_wobble * (0.6 * sin(offset * 0.21 + k) + 0.4 * sin(offset * 0.53 + k * 1.7))
