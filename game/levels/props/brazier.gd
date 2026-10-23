extends Node3D
## Brasero: fuego de partículas y una luz cálida que parpadea (luz dinámica, D-009).

## Intensidad base de la luz.
@export var base_energy: float = 3.2
## Cuánto varía al parpadear (proporción de la base).
@export_range(0.0, 1.0) var flicker_amount: float = 0.18
## Velocidad del parpadeo.
@export var flicker_speed: float = 9.0

var _t: float = 0.0

@onready var _light: OmniLight3D = %Light


func _ready() -> void:
	_t = randf() * 100.0


func _process(delta: float) -> void:
	_t += delta * flicker_speed
	var n := sin(_t) * 0.5 + sin(_t * 2.3 + 1.7) * 0.3 + sin(_t * 5.1 + 0.4) * 0.2
	_light.light_energy = base_energy * (1.0 + n * flicker_amount)
