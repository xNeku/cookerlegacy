class_name Hitbox
extends Area2D
## Área que hace daño. La activa quien ataca durante la ventana de golpe.
## Quien recibe es la Hurtbox (ella detecta a la Hitbox).

## Emitida cuando este golpe impacta en una Hurtbox (para hitstop, sonido...).
signal hit_landed(hurtbox: Area2D)

## Pinta el área mientras está activa. Útil mientras no hay animación de ataque.
@export var show_debug_shape: bool = true
## Color del área pintada.
@export var debug_color: Color = Color(1, 0.85, 0.4, 0.45)

## Golpe actual (daño, empuje, hitstop, temblor...). Lo lee quien recibe y el feedback.
var attack: AttackData
## Dirección del golpe (para el empujón y las chispas).
var direction: Vector2 = Vector2.RIGHT
var damage: float:
	get:
		return attack.damage if attack else 0.0
var knockback: float:
	get:
		return attack.knockback if attack else 0.0

var _active_flag: bool = false
var _debug_visible: bool = false
var _rect_shape: RectangleShape2D
var _circle_shape: CircleShape2D

@onready var _shape: CollisionShape2D = %Shape


func _ready() -> void:
	# Cada instancia tiene sus propias formas, porque cambian de tamaño por golpe.
	_rect_shape = _shape.shape.duplicate()
	_circle_shape = CircleShape2D.new()
	_shape.shape = _rect_shape
	set_active(false)


## Prepara el área para el golpe `new_attack` en dirección `dir`.
func configure(new_attack: AttackData, dir: Vector2) -> void:
	attack = new_attack
	direction = dir
	rotation = dir.angle()
	if new_attack.radial:
		_circle_shape.radius = new_attack.hitbox_size.x / 2.0
		_shape.shape = _circle_shape
		_shape.position = Vector2.ZERO
	else:
		_rect_shape.size = new_attack.hitbox_size
		_shape.shape = _rect_shape
		_shape.position = Vector2(new_attack.hitbox_distance, 0.0)
	queue_redraw()


func set_active(active: bool) -> void:
	if active == _active_flag:
		return
	_active_flag = active
	_shape.set_deferred("disabled", not active)
	_debug_visible = active and show_debug_shape
	queue_redraw()


func is_active() -> bool:
	return _active_flag


## Dirección del empujón para quien está en `target_position`: la del golpe,
## o hacia fuera desde el centro si el golpe es radial.
func get_knockback_direction(target_position: Vector2) -> Vector2:
	if attack and attack.radial:
		var away := target_position - global_position
		return away.normalized() if not away.is_zero_approx() else direction
	return direction



func _draw() -> void:
	if not _debug_visible or attack == null:
		return
	if attack.radial:
		draw_circle(Vector2.ZERO, _circle_shape.radius, debug_color)
	else:
		draw_rect(Rect2(_shape.position - _rect_shape.size / 2.0, _rect_shape.size), debug_color)
