extends Node
## Autoload "HitStop": congela el juego un instante al impactar (da peso a los golpes).
## Uso: HitStop.freeze(0.05)

## Apagar para comparar cómo se siente sin hitstop.
@export var enabled: bool = true
## Velocidad del juego durante el congelado (0 = parado del todo).
@export_range(0.0, 1.0) var frozen_time_scale: float = 0.05

## Momento (tiempo real, s) en que acaba el congelado actual.
var _ends_at: float = 0.0


func freeze(duration: float) -> void:
	if not enabled or duration <= 0.0:
		return
	var ends := _real_now() + duration
	# Si ya hay un congelado más largo en marcha, no lo acortamos.
	if ends <= _ends_at:
		return
	_ends_at = ends
	Engine.time_scale = frozen_time_scale


# Cada frame mira el reloj real (no afectado por time_scale) y descongela al llegar.
func _process(_delta: float) -> void:
	if _ends_at > 0.0 and _real_now() >= _ends_at:
		_ends_at = 0.0
		Engine.time_scale = 1.0


func _real_now() -> float:
	return Time.get_ticks_usec() / 1_000_000.0
