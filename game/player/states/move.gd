extends PlayerState
## Andando. Movimiento analógico; la animación sigue la dirección cardinal más cercana.
## Levanta polvo cada pocos pasos.


func physics_update(delta: float) -> void:
	if try_start_action():
		return
	var input := player.get_move_input()
	if input.is_zero_approx():
		machine.change_to(&"Idle")
		return
	player.update_facing(input)
	player.accelerate_towards(input, delta)
	player.move_and_slide()
	player.play_animation("walk")
	player.update_walk_anim_speed()
	player.track_run_dust(delta)
