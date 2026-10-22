class_name HitFlash
extends Node
## Al recibir un golpe (señal de la Hurtbox), pone el sprite en blanco un instante
## y lo aplasta un poco. Reutilizable: muñecos, enemigos, jugador.

## Hurtbox que avisa de los golpes.
@export var hurtbox: Hurtbox
## Sprite (o cualquier CanvasItem) que parpadea. Se le pone el material del flash.
@export var target: Node2D
## Material del flash (hit_flash_material.tres). Se duplica para cada dueño.
@export var flash_material: ShaderMaterial
## Color del destello.
@export var flash_color: Color = Color.WHITE
## Duración del destello (s).
@export var flash_time: float = 0.1
## Aplastón al recibir el golpe (0 = nada). Escala X sube y Y baja en esta proporción.
@export_range(0.0, 0.5) var squash_amount: float = 0.15
## Duración del aplastón (s).
@export var squash_time: float = 0.12

var _material: ShaderMaterial
var _base_scale: Vector2


func _ready() -> void:
	_material = flash_material.duplicate()
	_material.set_shader_parameter("flash_color", flash_color)
	target.material = _material
	_base_scale = target.scale
	hurtbox.hit_received.connect(_on_hit_received)


func _on_hit_received(_hitbox: Hitbox) -> void:
	_material.set_shader_parameter("flash_amount", 1.0)
	var flash := create_tween()
	flash.tween_method(_set_flash, 1.0, 0.0, flash_time)
	if squash_amount > 0.0:
		target.scale = _base_scale * Vector2(1.0 + squash_amount, 1.0 - squash_amount)
		var squash := create_tween()
		squash.tween_property(target, "scale", _base_scale, squash_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _set_flash(value: float) -> void:
	_material.set_shader_parameter("flash_amount", value)
