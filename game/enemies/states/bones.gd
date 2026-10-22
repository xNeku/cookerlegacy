extends EnemyState
## Montón de huesos (rearmarse, Q-17). Solo si EnemyData.reassemble_enabled.
## Un golpe (vida `bones_health`) lo remata del todo. Si pasan `reassemble_time` s sin
## rematarlo, se recompone con `reassemble_health_ratio` de la vida y vuelve a pelear.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	enemy.is_bones = true
	enemy.hitbox.set_active(false)
	enemy.health.current = enemy.data.bones_health
	# Se puede pasar por encima del montón.
	enemy.set_deferred("collision_layer", 0)
	enemy.play_animation(&"bones", &"hurt")


func exit() -> void:
	enemy.is_bones = false
	enemy.set_deferred("collision_layer", 4)


func physics_update(delta: float) -> void:
	_time += delta
	enemy.apply_friction(delta)
	enemy.move_and_slide()
	# Tiembla al final, avisando de que se va a levantar.
	var left := enemy.data.reassemble_time - _time
	var shake := Vector2(randf_range(-1.0, 1.0), 0.0) if left < 0.8 else Vector2.ZERO
	enemy.set_sprite_offset(shake * enemy.windup_shake)
	if _time >= enemy.data.reassemble_time:
		enemy.set_sprite_offset(Vector2.ZERO)
		enemy.health.current = enemy.data.max_health * enemy.data.reassemble_health_ratio
		machine.change_to(&"Chase")
