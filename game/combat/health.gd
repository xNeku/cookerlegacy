class_name Health
extends Node
## Vida de cualquier cosa que pueda recibir daño.

signal damaged(amount: float, current: float)
signal died

@export var max_health: float = 100.0
## Si está activo, recibe daño pero nunca muere (muñecos de prueba).
@export var immortal: bool = false

var current: float


func _ready() -> void:
	current = max_health


func take_damage(amount: float) -> void:
	if current <= 0.0:
		return
	current = maxf(current - amount, 0.0)
	damaged.emit(amount, current)
	if current <= 0.0:
		if immortal:
			current = max_health
		else:
			died.emit()
