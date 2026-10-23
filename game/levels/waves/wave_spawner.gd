class_name WaveSpawner
extends Node2D
## Lanza oleadas en orden. Cuando muere el último enemigo de una, espera su `delay`
## y lanza la siguiente. Los enemigos salen en sus puntos de aparición: los Marker2D
## hijos de este nodo (muévelos en el editor). Base de las hordas/barreras de Fase 2.

## Al empezar una oleada (número desde 1 y total de enemigos).
signal wave_started(wave_number: int, enemy_count: int)
## Cada vez que muere uno (cuántos quedan).
signal enemies_left_changed(left: int)
## Al limpiar una oleada.
signal wave_cleared(wave_number: int)

## Las oleadas, en orden.
@export var waves: Array[WaveData] = []
## Dónde se añaden los enemigos (el nodo World con Y-sort).
@export var container: Node2D
## Al acabar la última, vuelve a la primera.
@export var loop: bool = true
## Empieza solo al cargar el nivel.
@export var autostart: bool = true
## Dispersión alrededor de cada punto de aparición (px).
@export var spawn_radius: float = 30.0

var current_wave: int = 0
var _alive: int = 0
var _spawn_points: Array[Marker2D] = []


func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
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
	await get_tree().create_timer(wave.delay).timeout
	_spawn_wave(wave)
	wave_started.emit(current_wave, wave.total_count())
	enemies_left_changed.emit(_alive)


func _spawn_wave(wave: WaveData) -> void:
	for entry in wave.entries:
		# Cada línea sale junta en un punto al azar (los grupos llegan como grupo).
		var point := _random_point()
		for i in entry.count:
			var enemy := entry.enemy_scene.instantiate() as Enemy
			container.add_child(enemy)
			enemy.global_position = point + Vector2.from_angle(randf() * TAU) * randf() * spawn_radius
			enemy.died.connect(_on_enemy_died)
			_alive += 1


func _random_point() -> Vector2:
	if _spawn_points.is_empty():
		return global_position
	return _spawn_points.pick_random().global_position


func _on_enemy_died(_enemy: Enemy) -> void:
	_alive -= 1
	enemies_left_changed.emit(_alive)
	if _alive <= 0:
		wave_cleared.emit(current_wave)
		_launch_next()
