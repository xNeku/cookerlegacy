class_name SlashFx
extends Node3D
## Tajo del arma: un arco en el suelo que barre y se apaga (shader slash.gdshader).
## Lo crea el atacante al empezar cada golpe; color, arco, radio, sentido y vueltas
## salen del AttackData (grupo "Efecto visual").

## Lo que tarda el barrido (s).
@export var sweep_time: float = 0.07
## Lo que tarda en apagarse después (s).
@export var fade_time: float = 0.18
## Brillo (más de 1 = bloom).
@export var energy: float = 4.0
## Pixela el tajo a la resolución del arte (32 px por metro).
@export var pixel_snap: bool = true

var _color: Color = Color(1.0, 0.85, 0.55)
var _arc: float = 150.0
var _radius: float = 0.9
var _flip: bool = false
var _turns: float = 0.0
var _duration: float = 0.3
var _material: ShaderMaterial

@onready var _mesh: MeshInstance3D = %Mesh


func setup(color: Color, attack: AttackData) -> void:
	_color = color
	if attack:
		_arc = attack.vfx_arc_degrees
		_radius = attack.vfx_radius
		_flip = attack.vfx_flip
		_turns = attack.vfx_turns
		_duration = attack.duration


func _ready() -> void:
	_material = (_mesh.material_override as ShaderMaterial).duplicate()
	_mesh.material_override = _material
	_mesh.scale = Vector3(_radius * 2.0, 1.0, _radius * 2.0)
	_material.set_shader_parameter("color", _color)
	_material.set_shader_parameter("arc_degrees", _arc)
	_material.set_shader_parameter("flip", -1.0 if _flip else 1.0)
	_material.set_shader_parameter("energy", energy)
	_material.set_shader_parameter("pixel_steps", _radius * 2.0 * Flat.PIXELS_PER_METER if pixel_snap else 0.0)
	var tween := create_tween()
	if _turns > 0.0:
		# Giro: arco con estela larga dando vueltas durante todo el golpe.
		_set_param(1.0, "progress")
		_set_param(0.95, "trail")
		var spin := TAU * _turns * (-1.0 if _flip else 1.0)
		tween.tween_property(self, "rotation:y", rotation.y + spin, _duration)
		tween.parallel().tween_method(_set_param.bind("fade"), 1.0, 0.0, fade_time).set_delay(maxf(_duration - fade_time, 0.0))
	else:
		_set_param(0.0, "progress")
		tween.tween_method(_set_param.bind("progress"), 0.0, 1.0, sweep_time) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_method(_set_param.bind("fade"), 1.0, 0.0, fade_time)
	tween.tween_callback(queue_free)


func _set_param(value: float, param: String) -> void:
	_material.set_shader_parameter(param, value)
