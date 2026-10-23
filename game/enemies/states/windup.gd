extends EnemyState
## Aviso: se para, mira al cocinero, brilla, tiembla y marca en el suelo dónde va a pegar
## durante `windup_time`. Es la ventana para esquivar o para interrumpirle de un golpe.
## La dirección queda fijada en el último momento (al pasar a Attack).

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	enemy.face(enemy.direction_to_target())
	enemy.play_animation(&"windup", &"idle")


func exit() -> void:
	enemy.sprite_fx.set_tint(enemy.windup_color, 0.0)
	enemy.set_sprite_offset(Vector3.ZERO)
	enemy.hide_telegraph()


func physics_update(delta: float) -> void:
	_time += delta
	enemy.apply_friction(delta)
	enemy.move_and_slide()
	var dir := enemy.direction_to_target()
	enemy.face(dir)
	var ratio := clampf(_time / enemy.data.windup_time, 0.0, 1.0)
	enemy.sprite_fx.set_tint(enemy.windup_color, ratio * 0.7)
	enemy.set_sprite_offset(Vector3(randf_range(-1.0, 1.0), 0.0, 0.0) * enemy.windup_shake * ratio)
	enemy.update_telegraph(dir, ratio)
	if _time >= enemy.data.windup_time:
		machine.change_to(&"Attack")
