extends EnemyState
## Levantado por los aires (knockup): vuela en parábola sin poder hacer nada y cae.
## Los golpes en el aire le hacen daño y le empujan, pero no le bajan antes.
## Al caer levanta polvo.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	enemy.hide_telegraph()
	enemy.play_animation(&"hurt", &"idle")


func exit() -> void:
	enemy.set_height(0.0)


func physics_update(delta: float) -> void:
	_time += delta
	var t := clampf(_time / enemy.knockup_duration, 0.0, 1.0)
	enemy.set_height(enemy.knockup_height * 4.0 * t * (1.0 - t))
	# En el aire frena menos: sale despedido más lejos.
	enemy.planar_velocity = enemy.planar_velocity.move_toward(Vector2.ZERO, enemy.data.friction * 0.3 * delta)
	enemy.move_and_slide()
	if t >= 1.0:
		FxSpawner.spawn(enemy, enemy.land_fx, Vector3(enemy.global_position.x, 0.02, enemy.global_position.z))
		get_tree().call_group(&"game_camera", &"shake", 0.03, 0.08)
		machine.change_to(&"Hurt")
