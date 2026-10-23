extends EnemyState
## Ataque: apunta al cocinero al empezar (no le sigue después: así el dash esquiva),
## embiste (`lunge_speed`) y activa su Hitbox en la ventana de daño del AttackData.

var _time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	var attack := enemy.data.attack
	var dir := enemy.direction_to_target()
	enemy.face(dir)
	enemy.hitbox.configure(attack, dir)
	enemy.planar_velocity = dir * attack.lunge_speed
	enemy.play_animation(&"attack", &"idle")
	FxSpawner.attach(enemy, attack.vfx_scene, Vector3(0.0, enemy.hitbox.position.y, 0.0),
			Flat.yaw(dir), attack.vfx_color, attack)


func exit() -> void:
	enemy.hitbox.set_active(false)


func physics_update(delta: float) -> void:
	var attack := enemy.data.attack
	_time += delta
	enemy.hitbox.set_active(_time >= attack.hit_start and _time < attack.hit_end)
	if _time >= attack.lunge_time:
		enemy.apply_friction(delta)
	enemy.move_and_slide()
	if _time >= attack.duration:
		enemy.start_attack_cooldown()
		machine.change_to(&"Recover")
