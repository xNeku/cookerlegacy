class_name GameCamera
extends Camera3D
## Cámara HD-2D: sigue al objetivo desde arriba y en diagonal (en perspectiva), con suavizado,
## límites, temblor y "punch" de zoom. El desenfoque (tilt-shift) está en `attributes`
## (CameraAttributesPractical › DOF) de la escena.
## Está en el grupo "game_camera": cualquiera puede pedir
## get_tree().call_group(&"game_camera", &"shake", fuerza_m, duracion) o &"punch".

## Nodo al que sigue (normalmente el Player).
@export var target: Node3D

@export_group("Encuadre")
## Inclinación hacia abajo (grados). 90 = cenital; menos = más de lado.
@export_range(10.0, 89.0) var pitch_degrees: float = 34.0
## Distancia al objetivo (m).
@export var distance: float = 18.0
## Punto al que mira, respecto a los pies del objetivo (m). Algo de altura centra el cuerpo.
@export var look_offset: Vector3 = Vector3(0.0, 0.5, 0.0)
## Suavizado del seguimiento (más alto = sigue más pegado).
@export var follow_speed: float = 7.0
## Sigue la altura del salto (si no, la cámara no sube al saltar).
@export var follow_height: bool = false

## Adelanta el encuadre hacia donde se mueve el objetivo (s de anticipación; 0 = nada).
## Ayuda a ver lo que viene cuando avanzas.
@export var lead_time: float = 0.0
## Suavizado de ese adelanto (más alto = reacciona antes).
@export var lead_smoothing: float = 2.5

@export_group("Límites (m)")
@export var limit_enabled: bool = true
@export var limit_min: Vector2 = Vector2(6.5, 3.0)
@export var limit_max: Vector2 = Vector2(23.5, 12.0)

@export_group("Temblor")
## Apagar para comparar sin temblor.
@export var shake_enabled: bool = true
## Tope del temblor (m), por fuertes que se junten.
@export var max_shake: float = 0.3

@export_group("Punch de zoom")
## Lo que tarda en volver el zoom tras un "punch" (s).
@export var punch_return_time: float = 0.18

var _focus: Vector3
var _lead: Vector3
var _shake_strength: float = 0.0
var _shake_time: float = 0.0
var _shake_left: float = 0.0
var _base_fov: float
var _punch_tween: Tween


func _ready() -> void:
	add_to_group(&"game_camera")
	_base_fov = fov
	if target:
		_focus = _target_point()
	_place()


## Tiembla `strength` metros durante `duration` segundos, apagándose poco a poco.
func shake(strength: float, duration: float) -> void:
	if not shake_enabled:
		return
	# Si ya está temblando más fuerte, no lo pisamos con uno flojo.
	if strength >= _shake_strength * (_shake_left / maxf(_shake_time, 0.001)):
		_shake_strength = minf(strength, max_shake)
		_shake_time = duration
		_shake_left = duration


## Zoom rápido hacia dentro (`degrees` de FOV) que vuelve solo. Para golpes gordos.
func punch(degrees: float) -> void:
	if _punch_tween:
		_punch_tween.kill()
	fov = _base_fov - degrees
	_punch_tween = create_tween().set_ignore_time_scale(true)
	_punch_tween.tween_property(self, "fov", _base_fov, punch_return_time) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	# Tiempo real: el temblor sigue durante el hitstop (se nota más el golpe).
	var real_delta := delta / maxf(Engine.time_scale, 0.001)
	if target:
		_update_lead(delta)
		_focus = _focus.lerp(_target_point(), 1.0 - exp(-follow_speed * delta))
	_place()
	if _shake_left > 0.0:
		_shake_left -= real_delta
		var fade := clampf(_shake_left / _shake_time, 0.0, 1.0)
		h_offset = randf_range(-1.0, 1.0) * _shake_strength * fade
		v_offset = randf_range(-1.0, 1.0) * _shake_strength * fade
	else:
		h_offset = 0.0
		v_offset = 0.0


func _update_lead(delta: float) -> void:
	var wanted := Vector3.ZERO
	if lead_time > 0.0 and target is CharacterBody3D:
		var v := (target as CharacterBody3D).velocity
		wanted = Vector3(v.x, 0.0, v.z) * lead_time
	_lead = _lead.lerp(wanted, 1.0 - exp(-lead_smoothing * delta))


func _target_point() -> Vector3:
	var p := target.global_position + _lead
	if not follow_height:
		p.y = 0.0
	if limit_enabled:
		p.x = clampf(p.x, limit_min.x, limit_max.x)
		p.z = clampf(p.z, limit_min.y, limit_max.y)
	return p + look_offset


func _place() -> void:
	var pitch := deg_to_rad(pitch_degrees)
	global_position = _focus + Vector3(0.0, sin(pitch), cos(pitch)) * distance
	rotation = Vector3(-pitch, 0.0, 0.0)
