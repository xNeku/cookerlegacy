extends EnemyState
## Aviso: se para, mira al cocinero y "se prepara" (tinte + temblor de placeholder)
## durante `windup_time`. Es la ventana para esquivar o para interrumpirle de un golpe.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	enemy.face(enemy.direction_to_target())
	enemy.play_animation(&"windup", &"idle")


func exit() -> void:
	enemy.sprite.modulate = Color.WHITE
	enemy.set_sprite_offset(Vector2.ZERO)


func physics_update(delta: float) -> void:
	_time += delta
	enemy.apply_friction(delta)
	enemy.move_and_slide()
	enemy.face(enemy.direction_to_target())
	var ratio := clampf(_time / enemy.data.windup_time, 0.0, 1.0)
	enemy.sprite.modulate = Color.WHITE.lerp(enemy.windup_color, ratio)
	enemy.set_sprite_offset(Vector2(randf_range(-1.0, 1.0), 0.0) * enemy.windup_shake)
	if _time >= enemy.data.windup_time:
		machine.change_to(&"Attack")
