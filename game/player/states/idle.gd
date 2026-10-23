extends PlayerState
## Quieto. Frena lo que quede de inercia y espera input.


func enter(_previous: State) -> void:
	player.sprite.speed_scale = 1.0
	player.play_animation("idle")


func physics_update(delta: float) -> void:
	if try_start_action():
		return
	if not player.get_move_input().is_zero_approx():
		machine.change_to(&"Move")
		return
	player.apply_friction(delta)
	player.move_and_slide()
	player.play_animation("idle")
