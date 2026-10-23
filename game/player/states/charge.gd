extends PlayerState
## Manteniendo △: carga. Soltar antes de llenarse = golpe fuerte normal.
## Soltar con la carga llena = ataque cargado. Te mueves despacio mientras cargas.
## Dash, salto y giro cortan la carga en cualquier momento.
## Efecto: el cocinero se va encendiendo, chispas que se juntan hacia él y, al llenarse,
## un destello con onda y un temblor.

var _held: float = 0.0
var _full: bool = false


func enter(_previous: State) -> void:
	_held = 0.0
	_full = false
	player.sprite.speed_scale = 1.0
	player.charge_particles.emitting = true


func exit() -> void:
	player.sprite_fx.set_tint(player.charge_color, 0.0)
	player.set_sprite_shake(Vector3.ZERO)
	player.charge_particles.emitting = false


func physics_update(delta: float) -> void:
	if try_dash() or try_jump() or try_spin():
		return
	if not Input.is_action_pressed("attack_heavy"):
		machine.change_to(&"ChargedAttack" if _full else &"HeavyAttack")
		return

	_held += delta
	var input := player.get_move_input()
	player.steer(input, player.charge_move_multiplier, delta)
	player.move_and_slide()
	player.update_facing(player.get_attack_direction())
	player.play_animation("charge", "idle" if input.is_zero_approx() else "walk")
	_update_visual()


func _update_visual() -> void:
	var ratio := clampf(_held / player.charge_time, 0.0, 1.0)
	if ratio >= 1.0 and not _full:
		_full = true
		# ¡Lleno! Destello, onda y temblorcillo para que se note sin mirar.
		player.sprite_fx.flash(player.charge_color)
		player.spawn_ring(player.charge_color)
		get_tree().call_group(&"game_camera", &"shake", 0.03, 0.1)
	if _full:
		var pulse := 0.55 + 0.25 * sin(player.game_time() * 30.0)
		player.sprite_fx.set_tint(player.charge_color, pulse)
		player.set_sprite_shake(Vector3(randf_range(-1.0, 1.0), 0.0, 0.0) * player.charge_full_shake)
	else:
		player.sprite_fx.set_tint(player.charge_color, ratio * 0.6)
