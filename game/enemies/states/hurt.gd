extends EnemyState
## Recibe un golpe: sale empujado (la velocidad la pone Enemy al recibirlo) y queda
## aturdido `hurt_time`. Interrumpe cualquier cosa, también el aviso.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	enemy.hide_telegraph()
	enemy.play_animation(&"hurt", &"idle")


func physics_update(delta: float) -> void:
	_time += delta
	enemy.apply_friction(delta)
	enemy.move_and_slide()
	if _time >= enemy.data.hurt_time:
		machine.change_to(&"Chase")
