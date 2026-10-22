extends EnemyState
## Recuperación tras atacar: se queda vendido `recovery_time`. Ventana para castigarle.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	enemy.play_animation(&"recover", &"idle")


func physics_update(delta: float) -> void:
	_time += delta
	enemy.apply_friction(delta)
	enemy.move_and_slide()
	if _time >= enemy.data.recovery_time:
		machine.change_to(&"Chase")
