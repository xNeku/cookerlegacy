extends PlayerState
## Recibiendo un golpe: empujado y aturdido `hurt_time`. El dash lo corta pronto
## (`hurt_dash_cancel_from`), para salir del lío como en Hades.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	player.sprite.speed_scale = 1.0
	player.play_animation("hurt", "idle")


func physics_update(delta: float) -> void:
	_time += delta
	if _time >= player.hurt_dash_cancel_from and try_dash():
		return
	player.apply_friction(delta)
	player.move_and_slide()
	if _time >= player.hurt_time:
		if try_start_action():
			return
		machine.change_to(player.free_state())
