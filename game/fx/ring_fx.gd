class_name RingFx
extends Node3D
## Onda expansiva en el suelo (ataque cargado, carga llena, giro...).

## Radio final (m) si el golpe no dice otro.
@export var radius: float = 1.6
## Lo que tarda en crecer y apagarse (s).
@export var duration: float = 0.35

var _color: Color = Color(1.0, 0.7, 0.35)

@onready var _mesh: MeshInstance3D = %Mesh


func setup(color: Color, attack: AttackData) -> void:
	_color = color
	if attack:
		radius = attack.hitbox_size.x * 0.6 if attack.radial else attack.vfx_radius * 1.5


func _ready() -> void:
	var mat := (_mesh.material_override as ShaderMaterial).duplicate() as ShaderMaterial
	_mesh.material_override = mat
	_mesh.scale = Vector3(radius * 2.0, 1.0, radius * 2.0)
	mat.set_shader_parameter("color", _color)
	mat.set_shader_parameter("pixel_steps", radius * 2.0 * Flat.PIXELS_PER_METER)
	var tween := create_tween()
	tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("progress", v), 0.05, 1.0, duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
