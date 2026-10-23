class_name OneshotFx
extends Node3D
## Efecto de un solo disparo (impacto, polvo, muerte...): al entrar en escena lanza todas
## sus partículas hijas y, si tiene un nodo "Flash" (estrella), lo hace crecer y apagarse.
## Se borra solo al acabar.

## Tiñe las partículas con el color que le pasen (p. ej. el del golpe).
@export var tint_particles: bool = true
## Tiempo hasta borrarse (s). Que cubra la vida de las partículas.
@export var lifetime: float = 0.8
## Tamaño final del destello (m) y lo que tarda (s).
@export var flash_size: float = 0.9
@export var flash_time: float = 0.12

var _color: Color = Color.WHITE


func setup(color: Color, _attack: AttackData) -> void:
	_color = color


func _ready() -> void:
	for child in get_children():
		if child is CPUParticles3D:
			if tint_particles:
				child.color = _color
			child.emitting = true
	var flash := get_node_or_null(^"Flash") as MeshInstance3D
	if flash:
		var mat := (flash.material_override as ShaderMaterial).duplicate() as ShaderMaterial
		flash.material_override = mat
		mat.set_shader_parameter("color", _color.lerp(Color.WHITE, 0.4))
		flash.scale = Vector3.ONE * flash_size * 0.3
		var tween := create_tween()
		tween.tween_property(flash, "scale", Vector3.ONE * flash_size, flash_time * 0.4) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("fade", v), 1.0, 0.0, flash_time * 0.6)
	get_tree().create_timer(lifetime, false).timeout.connect(queue_free)
