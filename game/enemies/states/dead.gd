extends EnemyState
## Muerto: deja de colisionar y de recibir golpes, sale despedido, se desvanece y se borra.
## (El loot que vuela al almacén se enganchará aquí en Fase 2.)


func enter(_previous: State) -> void:
	enemy.hitbox.set_active(false)
	enemy.hurtbox.set_deferred("monitoring", false)
	# Solo choca con paredes (no con el cocinero ni otros enemigos).
	enemy.set_deferred("collision_layer", 0)
	enemy.set_deferred("collision_mask", 1)
	enemy.play_animation(&"dead", &"hurt")
	var tween := enemy.create_tween()
	tween.tween_property(enemy.sprite, "modulate:a", 0.0, enemy.death_time)
	tween.parallel().tween_property(enemy.shadow, "modulate:a", 0.0, enemy.death_time)
	tween.tween_callback(enemy.queue_free)


func physics_update(delta: float) -> void:
	enemy.apply_friction(delta)
	enemy.move_and_slide()
