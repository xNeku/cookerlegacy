extends PlayerState
## Tumbado: sin vida. Golpe seco (flash, congelado, temblor), sale despedido, se pone gris
## y se queda en el suelo. No sale de aquí: quien lleve la partida (NightRun) decide qué pasa.


func enter(_previous: State) -> void:
	player.invulnerable = true
	player.sprite.speed_scale = 1.0
	player.play_animation("hurt", "idle", true)
	player.sprite_fx.flash(Color.WHITE, 0.35)
	HitStop.freeze(player.death_hitstop)
	get_tree().call_group(&"game_camera", &"shake", player.death_shake, 0.4)
	get_tree().call_group(&"game_camera", &"punch", 4.0)
	player.spawn_dust(true)
	var tween := player.create_tween()
	tween.tween_interval(0.25)
	tween.tween_property(player.sprite, "scale", Vector3(1.3, 0.25, 1.0), 0.25) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_method(func(a: float) -> void: player.sprite_fx.set_tint(player.death_color, a), 0.0, 0.7, 0.4)


func physics_update(delta: float) -> void:
	player.apply_friction(delta * 0.4)
	player.move_and_slide()
