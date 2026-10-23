extends PlayerState
## Lo mueve el juego, no el jugador: camina solo por los puntos que le pasen
## (`player.walk_path()`), por ejemplo al entrar en el túnel. Sin input.
## Al llegar al último punto avisa con `scripted_walk_finished` y se queda quieto.


func enter(_previous: State) -> void:
	player.sprite.speed_scale = 1.0


func physics_update(delta: float) -> void:
	if player.scripted_points.is_empty():
		player.apply_friction(delta)
		player.move_and_slide()
		player.play_animation("idle")
		return
	var target: Vector3 = player.scripted_points[0]
	var to := Flat.of(target) - player.ground_position
	if to.length() < 0.15:
		player.scripted_points.pop_front()
		if player.scripted_points.is_empty():
			player.scripted_walk_finished.emit()
		return
	var dir := to.normalized()
	player.update_facing(dir)
	player.planar_velocity = dir * player.max_speed * player.scripted_speed
	player.move_and_slide()
	player.play_animation("walk")
	player.track_run_dust(delta)
