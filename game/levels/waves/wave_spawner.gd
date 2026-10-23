class_name WaveSpawner
extends Node3D
## Lanza oleadas en orden. Cuando muere el último enemigo de una, espera su `delay`
## y lanza la siguiente. Los enemigos salen en sus puntos de aparición: los Marker3D
## hijos de este nodo (muévelos en el editor). Base de las hordas/barreras de Fase 2.

## Al empezar una oleada (número desde 1 y total de enemigos).
signal wave_started(wave_number: int, enemy_count: int)
## Cada vez que muere uno (cuántos quedan).
signal enemies_left_changed(left: int)
## Al limpiar una oleada.
signal wave_cleared(wave_number: int)

## Las oleadas, en orden.
@export var waves: Array[WaveData] = []
## Dónde se añaden los enemigos (el nodo World del nivel).
@export var container: Node3D
## Al acabar la última, vuelve a la primera.
@export var loop: bool = true
## Empieza solo al cargar el nivel.
@export var autostart: bool = true
## Dispersión alrededor de cada punto de aparición (m).
@export var spawn_radius: float = 0.9
## Efecto al aparecer cada enemigo (humo). Vacío = sin efecto.
@export var spawn_fx: PackedScene

var current_wave: int = 0
var _alive: int = 0
var _spawn_points: Array[Marker3D] = []


func _ready() -> void:
	for child in get_children():
		if child is Marker3D:
			_spawn_points.append(child)
	if autostart:
		start.call_deferred()


func start() -> void:
	current_wave = 0
	_launch_next()


func _launch_next() -> void:
	if waves.is_empty():
		return
	if current_wave >= waves.size():
		if not loop:
			return
		current_wave = 0
	var wave := waves[current_wave]
	current_wave += 1
	await get_tree().create_timer(wave.delay, false).timeout
	_spawn_wave(wave)
	wave_started.emit(current_wave, wave.total_count())
	enemies_left_changed.emit(_alive)


func _spawn_wave(wave: WaveData) -> void:
	for entry in wave.entries:
		# Cada línea sale junta en un punto al azar (los grupos llegan como grupo).
		var point := _random_point()
		for i in entry.count:
			var enemy := entry.enemy_scene.instantiate() as Enemy
			var offset := Vector2.from_angle(randf() * TAU) * randf() * spawn_radius
			enemy.position = point + Flat.to3(offset)
			container.add_child(enemy)
			enemy.died.connect(_on_enemy_died)
			FxSpawner.spawn(self, spawn_fx, enemy.global_position + Vector3(0, 0.2, 0))
			_alive += 1


func _random_point() -> Vector3:
	if _spawn_points.is_empty():
		return Vector3(global_position.x, 0.0, global_position.z)
	var p: Vector3 = _spawn_points.pick_random().global_position
	return Vector3(p.x, 0.0, p.z)


func _on_enemy_died(_enemy: Enemy) -> void:
	_alive -= 1
	enemies_left_changed.emit(_alive)
	if _alive <= 0:
		wave_cleared.emit(current_wave)
		_launch_next()
