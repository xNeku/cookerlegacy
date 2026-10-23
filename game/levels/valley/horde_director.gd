class_name HordeDirector
extends Node
## Va soltando bichos sin parar por delante del cocinero mientras avanza por el valle.
## Mantiene un número de enemigos vivos que sube cuanto más lejos llegas.
## Los que se quedan muy atrás desaparecen (no cuentan como muertos).
## Aparecen fuera de la pantalla, más adelante en el camino, y la mayoría vienen a por ti.

signal enemy_spawned(enemy: Enemy)
signal enemy_killed(enemy: Enemy)

@export var path: ValleyPath
## A quién se mide el avance (el cocinero).
@export var player: Node3D
## Dónde se añaden los enemigos (el nodo World).
@export var container: Node3D
## Grupos que pueden salir.
@export var entries: Array[HordeEntry] = []
## Apágalo para pasear por el valle sin bichos.
@export var enabled: bool = true

@export_group("Cantidad")
## Enemigos vivos a la vez al principio del valle.
@export var alive_at_start: int = 5
## Enemigos vivos a la vez al final del valle.
@export var alive_at_end: int = 16
## Cómo sube la cantidad a lo largo del valle (x = 0 inicio, 1 final; y = 0..1 entre los
## dos valores de arriba). Vacía = sube en línea recta.
@export var density_curve: Curve
## Espera mínima entre grupos (s).
@export var group_interval: float = 0.9
## Metros del principio sin bichos (para arrancar tranquilo).
@export var safe_start: float = 6.0

@export_group("Dónde salen")
## Distancia por delante del cocinero (m, mínimo y máximo), a lo largo del camino.
@export var spawn_ahead: Vector2 = Vector2(15.0, 21.0)
## Separación de los bordes (m).
@export var edge_margin: float = 1.2
## Lo que se reparten los de un mismo grupo (m).
@export var group_spread: float = 1.3
## Si se quedan más atrás que esto (m), desaparecen.
@export var despawn_behind: float = 22.0
## Parte de los bichos que vienen a por ti desde que aparecen (el resto espera a verte).
@export_range(0.0, 1.0) var hunter_chance: float = 0.75
## Humo al aparecer.
@export var spawn_fx: PackedScene

var kills: int = 0
var _alive: Array[Enemy] = []
var _cooldown: float = 0.0


func _physics_process(delta: float) -> void:
	_alive = _alive.filter(func(e: Enemy) -> bool: return is_instance_valid(e) and not e.is_queued_for_deletion())
	if path == null or player == null:
		return
	var here := path.offset_of(player.global_position)
	_despawn_behind(here)
	_cooldown -= delta
	if not enabled or _cooldown > 0.0 or here < safe_start:
		return
	if _alive.size() < target_alive(here):
		_spawn_group(here)
		_cooldown = group_interval


## Cuántos vivos quiere tener con el cocinero en `distance` m.
func target_alive(distance: float) -> int:
	var t := clampf(distance / maxf(path.get_length(), 1.0), 0.0, 1.0)
	if density_curve:
		t = density_curve.sample(t)
	return roundi(lerpf(alive_at_start, alive_at_end, t))


func _spawn_group(here: float) -> void:
	var entry := _pick_entry(here)
	if entry == null or entry.enemy_scene == null:
		return
	var offset := here + randf_range(spawn_ahead.x, spawn_ahead.y)
	if offset > path.get_length() - 1.0:
		return
	var half := path.half_width_at(offset) - edge_margin
	var center := path.point_at(offset, randf_range(-half, half))
	var count := mini(randi_range(entry.group_size.x, entry.group_size.y), target_alive(here) - _alive.size() + 1)
	var hunters := randf() < hunter_chance
	for i in maxi(count, 1):
		var enemy := entry.enemy_scene.instantiate() as Enemy
		var spread := Vector2.from_angle(randf() * TAU) * randf() * group_spread
		enemy.position = center + Vector3(spread.x, 0.0, spread.y)
		enemy.always_chase = hunters
		container.add_child(enemy)
		enemy.died.connect(_on_enemy_died)
		FxSpawner.spawn(container, spawn_fx, enemy.global_position + Vector3(0, 0.2, 0))
		_alive.append(enemy)
		enemy_spawned.emit(enemy)


func _pick_entry(distance: float) -> HordeEntry:
	var pool := entries.filter(func(e: HordeEntry) -> bool: return e.is_available(distance))
	var total := 0.0
	for e in pool:
		total += e.weight
	var roll := randf() * total
	for e in pool:
		roll -= e.weight
		if roll <= 0.0:
			return e
	return pool.back() if not pool.is_empty() else null


func _despawn_behind(here: float) -> void:
	for enemy in _alive:
		if path.offset_of(enemy.global_position) < here - despawn_behind:
			_alive.erase(enemy)
			enemy.queue_free()
			return  # Uno por frame basta.


func _on_enemy_died(enemy: Enemy) -> void:
	_alive.erase(enemy)
	kills += 1
	enemy_killed.emit(enemy)
