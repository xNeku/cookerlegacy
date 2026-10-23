class_name DamageNumber
extends Label3D
## Número de daño que salta del enemigo, sube y se apaga.

## Altura que sube (m) y lo que dura (s).
@export var rise: float = 0.55
@export var lifetime: float = 0.65
## Desvío lateral aleatorio (m), para que varios golpes seguidos no se tapen.
@export var spread: float = 0.25

var _big: bool = false


func setup(color: Color, value: float, big: bool) -> void:
	text = str(roundi(value))
	modulate = color
	_big = big


func _ready() -> void:
	var base := Vector3.ONE * (1.35 if _big else 1.0)
	scale = base * 1.7
	var end := position + Vector3(randf_range(-spread, spread), rise, 0.0)
	var tween := create_tween()
	tween.tween_property(self, "scale", base, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "position", end, lifetime).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, lifetime * 0.35).set_delay(lifetime * 0.65)
	tween.parallel().tween_property(self, "outline_modulate:a", 0.0, lifetime * 0.35).set_delay(lifetime * 0.65)
	tween.tween_callback(queue_free)
