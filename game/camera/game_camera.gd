class_name GameCamera
extends Camera2D
## Cámara que sigue a un objetivo. El suavizado y los límites son propiedades de Camera2D
## (Inspector › Position Smoothing / Limit). Tiene temblor (shake) para los impactos.
## Está en el grupo "game_camera": cualquiera puede pedir un temblor con
## get_tree().call_group(&"game_camera", &"shake", fuerza, duracion).

## Nodo al que sigue (normalmente el Player).
@export var target: Node2D
## Apagar para comparar sin temblor.
@export var shake_enabled: bool = true
## Tope de desplazamiento del temblor (px), por fuertes que se junten.
@export var max_shake: float = 8.0

var _shake_strength: float = 0.0
var _shake_time: float = 0.0
var _shake_left: float = 0.0


func _ready() -> void:
	add_to_group(&"game_camera")
	if target:
		global_position = target.global_position
		reset_smoothing()


## Tiembla `strength` píxeles durante `duration` segundos, apagándose poco a poco.
func shake(strength: float, duration: float) -> void:
	if not shake_enabled:
		return
	# Si ya está temblando más fuerte, no lo pisamos con uno flojo.
	if strength >= _shake_strength * (_shake_left / maxf(_shake_time, 0.001)):
		_shake_strength = minf(strength, max_shake)
		_shake_time = duration
		_shake_left = duration


func _process(delta: float) -> void:
	if _shake_left <= 0.0:
		offset = Vector2.ZERO
		return
	_shake_left -= delta
	var fade := clampf(_shake_left / _shake_time, 0.0, 1.0)
	# Redondeado a píxel entero: en pixel art, temblores con decimales se ven borrosos.
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength * fade
	offset = offset.round()


func _physics_process(_delta: float) -> void:
	if target:
		global_position = target.global_position
