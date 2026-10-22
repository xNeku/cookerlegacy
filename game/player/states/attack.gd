extends PlayerState
## Combo □. Encadena golpes del ComboData del Player si se pulsa a tiempo.
## Pulsar antes de `chain_from` se guarda y el siguiente golpe sale justo al llegar.

var _attack: AttackData
var _time: float = 0.0
var _buffered: bool = false


func enter(_previous: State) -> void:
	_begin(player.next_combo_step())


func exit() -> void:
	player.hitbox.set_active(false)


func physics_update(delta: float) -> void:
	_time += delta
	if Input.is_action_just_pressed("attack_light"):
		_buffered = true

	player.hitbox.set_active(_time >= _attack.hit_start and _time < _attack.hit_end)

	if _time >= _attack.lunge_time:
		player.apply_friction(delta)
	player.move_and_slide()

	if _buffered and _time >= _attack.chain_from and player.has_next_combo_step():
		_begin(player.next_combo_step())
		return

	if _time >= _attack.duration:
		player.finish_attack()
		var moving := not player.get_move_input().is_zero_approx()
		machine.change_to(&"Move" if moving else &"Idle")


func _begin(step: int) -> void:
	_attack = player.light_combo.attacks[step]
	_time = 0.0
	_buffered = false
	var dir := player.get_attack_direction()
	player.update_facing(dir)
	player.sprite.speed_scale = 1.0
	player.play_animation(_attack.animation, "idle")
	player.hitbox.set_active(false)
	player.hitbox.configure(_attack.hitbox_size, _attack.hitbox_distance, dir, _attack.damage, _attack.knockback)
	player.velocity = dir * _attack.lunge_speed
