extends EnemyState
## Muerto: deja de colisionar y de recibir golpes, sale despedido, destella, se encoge
## y desaparece en una nube. (El loot que vuela al almacén se enganchará aquí en Fase 2.)


func enter(_previous: State) -> void:
	enemy.hide_telegraph()
	enemy.hitbox.set_active(false)
	enemy.hurtbox.set_deferred("monitoring", false)
	# Solo choca con paredes (no con el cocinero ni otros enemigos).
	enemy.set_deferred("collision_layer", 0)
	enemy.set_deferred("collision_mask", 1)
	enemy.play_animation(&"dead", &"hurt")
	enemy.sprite_fx.flash(Color.WHITE, enemy.death_time)
	var tween := enemy.create_tween()
	tween.tween_interval(enemy.death_time * 0.5)
	tween.tween_callback(func() -> void:
		FxSpawner.spawn(enemy, enemy.death_fx, enemy.global_position + Vector3(0, 0.25, 0), 0.0, enemy.death_color))
	tween.tween_property(enemy.sprite, "scale", Vector3(1.4, 0.05, 1.0), enemy.death_time * 0.5) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(enemy.shadow, "scale", Vector3.ZERO, enemy.death_time * 0.5)
	tween.tween_callback(enemy.queue_free)


func physics_update(delta: float) -> void:
	enemy.apply_friction(delta)
	enemy.move_and_slide()
