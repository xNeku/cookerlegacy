extends PlayerState
## Salto. En vista cenital el cuerpo (y su colisión) sigue en el suelo:
## sube el sprite y la sombra se queda abajo y encoge. Te puedes mover en el aire.
## Aquí se enganchará el SaltoGolpe (salto + △) en Fase 4.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	player.sprite.speed_scale = 1.0


func exit() -> void:
	player.set_height(0.0)


func physics_update(delta: float) -> void:
	_time += delta
	var t := clampf(_time / player.jump_duration, 0.0, 1.0)
	# Parábola: 0 al despegar, 1 en lo alto (mitad del salto), 0 al aterrizar.
	player.set_height(player.jump_height * 4.0 * t * (1.0 - t))

	var input := player.get_move_input()
	player.update_facing(input)
	player.steer(input, player.jump_air_control, delta)
	player.move_and_slide()
	player.play_animation("jump", "idle")

	if t >= 1.0:
		machine.change_to(&"Idle" if input.is_zero_approx() else &"Move")
