extends PlayerState
## En el aire (subiendo o cayendo). La altura la lleva el Player con su gravedad;
## este estado solo controla el movimiento aéreo y qué se puede hacer en el aire:
## dash (aéreo), giro y atacar. Al tocar suelo vuelve a Idle/Move.
## Se entra tras saltar, o al acabar un dash/golpe estando en el aire.


func enter(_previous: State) -> void:
	player.sprite.speed_scale = 1.0


func physics_update(delta: float) -> void:
	if try_dash() or try_spin() or try_attack():
		return
	var input := player.get_move_input()
	player.update_facing(input)
	player.air_steer(input, delta)
	player.move_and_slide()
	# Dos poses: subiendo (frame 0) y cayendo (frame 1).
	player.play_animation("jump", "idle")
	if player.sprite.sprite_frames.get_frame_count(player.sprite.animation) > 1:
		player.sprite.pause()
		player.sprite.frame = 0 if player.height > 0.0 and player._vertical_speed > 0.0 else 1

	if not player.is_airborne():
		machine.change_to(player.free_state())
