class_name Hurtbox
extends Area2D
## Área que recibe golpes. Al entrar una Hitbox activa, aplica daño a `health`
## y avisa con `hit_received` (para empujón, flash, etc.).
## La forma se añade como hijo CollisionShape2D en la escena de cada dueño.

signal hit_received(hitbox: Hitbox)

## Vida a la que se resta el daño. Puede quedar vacía si solo interesa la señal.
@export var health: Health


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var hitbox := area as Hitbox
	if hitbox == null:
		return
	if health:
		health.take_damage(hitbox.damage)
	hit_received.emit(hitbox)
	hitbox.hit_landed.emit(self)
