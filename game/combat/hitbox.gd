class_name Hitbox
extends Area2D
## Área que hace daño. La activa quien ataca durante la ventana de golpe.
## Quien recibe es la Hurtbox (ella detecta a la Hitbox).

## Emitida cuando este golpe impacta en una Hurtbox (para hitstop, sonido...).
signal hit_landed(hurtbox: Area2D)

## Pinta el área mientras está activa. Útil mientras no hay animación de ataque.
@export var show_debug_shape: bool = true

var damage: float = 0.0
var knockback: float = 0.0
## Dirección del golpe (para el empujón).
var direction: Vector2 = Vector2.RIGHT

@onready var _shape: CollisionShape2D = %Shape
@onready var _debug_shape: ColorRect = %DebugShape


func _ready() -> void:
	# Cada instancia necesita su propia forma, porque cambiamos su tamaño por golpe.
	_shape.shape = _shape.shape.duplicate()
	set_active(false)


## Prepara el área para un golpe en `dir`.
func configure(size: Vector2, distance: float, dir: Vector2, hit_damage: float, hit_knockback: float) -> void:
	direction = dir
	damage = hit_damage
	knockback = hit_knockback
	rotation = dir.angle()
	(_shape.shape as RectangleShape2D).size = size
	_shape.position = Vector2(distance, 0.0)
	_debug_shape.size = size
	_debug_shape.position = _shape.position - size / 2.0


func set_active(active: bool) -> void:
	_shape.set_deferred("disabled", not active)
	_debug_shape.visible = active and show_debug_shape


func is_active() -> bool:
	return not _shape.disabled
