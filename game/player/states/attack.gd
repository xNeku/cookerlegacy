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

	var input := player.get_move_input()
	if _time >= _attack.lunge_time:
		player.steer(input, _attack.move_speed_multiplier, delta)
	player.move_and_slide()
	# Sin animación de ataque (placeholder): si te mueves pegando, anda en vez de patinar.
	player.play_animation(_attack.animation, "idle" if input.is_zero_approx() else "walk")

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
	player.hitbox.set_active(false)
	player.hitbox.configure(_attack.hitbox_size, _attack.hitbox_distance, dir, _attack.damage, _attack.knockback)
	# Conserva parte de la inercia y suma el pasito: así andar y pegar no frena en seco.
	player.velocity = player.velocity * player.attack_momentum_keep + dir * _attack.lunge_speed
