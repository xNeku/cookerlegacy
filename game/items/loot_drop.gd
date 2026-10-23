class_name LootDrop
extends Node3D
## Loot que suelta un enemigo. Salta fuera del cuerpo, bota, se queda un instante a la vista
## y sale volando al almacén (el nodo del grupo "storage_target", o hacia arriba si no hay).
## Al llegar se suma al almacén (autoload Storage). Nada que recoger: cero gestión.

## Qué es (lo pone quien lo suelta).
@export var item: ItemData

@export_group("Salto")
## Lo lejos que salta del cuerpo (m, mínimo y máximo).
@export var pop_distance: Vector2 = Vector2(0.5, 1.2)
## Altura del salto (m).
@export var pop_height: float = 0.9
## Duración del salto (s).
@export var pop_time: float = 0.42

@export_group("Vuelo al almacén")
## Tiempo a la vista en el suelo antes de salir volando (s).
@export var linger_time: float = 0.3
## Duración del vuelo (s).
@export var fly_time: float = 0.6
## Altura del arco del vuelo (m).
@export var fly_arc_height: float = 5.0
## Si no hay almacén en la escena, vuela hacia arriba esta distancia (m).
@export var fly_up_distance: float = 9.0

@onready var _icon: Sprite3D = %Icon
@onready var _shadow: Decal = %Shadow
@onready var _trail: CPUParticles3D = %Trail
@onready var _glow: OmniLight3D = %Glow

var _ground_target: Vector3
var _pop_start: Vector3
var _fly_start: Vector3
var _fly_end: Vector3


func _ready() -> void:
	if item:
		_icon.texture = item.icon
		_trail.color = item.color
		_glow.light_color = item.color
	var angle := randf() * TAU
	var dist := randf_range(pop_distance.x, pop_distance.y)
	_ground_target = global_position + Vector3(cos(angle), 0.0, sin(angle)) * dist
	_pop()


func _pop() -> void:
	_pop_start = global_position
	var tween := create_tween()
	tween.tween_method(_pop_step, 0.0, 1.0, pop_time)
	# Botecito al caer.
	tween.tween_property(_icon, "position:y", 0.45, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_icon, "position:y", 0.25, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_interval(linger_time)
	tween.tween_callback(_fly)


func _pop_step(t: float) -> void:
	var p := _pop_start.lerp(_ground_target, t)
	var y := 4.0 * pop_height * t * (1.0 - t)
	global_position = Vector3(p.x, 0.0, p.z)
	_icon.position.y = 0.25 + y
	_shadow.scale = Vector3.ONE * lerpf(1.0, 0.6, y / maxf(pop_height, 0.01))


func _fly() -> void:
	_fly_start = _icon.global_position
	var home := get_tree().get_first_node_in_group(&"storage_target") as Node3D
	_fly_end = home.global_position if home else _fly_start + Vector3(0, fly_up_distance, 0)
	_trail.emitting = true
	_shadow.visible = false
	var tween := create_tween()
	tween.tween_method(_fly_step, 0.0, 1.0, fly_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_arrive)


func _fly_step(t: float) -> void:
	var p := _fly_start.lerp(_fly_end, t)
	p.y += sin(t * PI) * fly_arc_height
	_icon.global_position = p
	_icon.scale = Vector3.ONE * lerpf(1.2, 0.5, t)


func _arrive() -> void:
	if item:
		Storage.add(item, 1)
	_icon.visible = false
	_glow.visible = false
	_trail.emitting = false
	await get_tree().create_timer(_trail.lifetime).timeout
	queue_free()
