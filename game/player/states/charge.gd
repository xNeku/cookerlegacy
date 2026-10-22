extends PlayerState
## Manteniendo △: carga. Soltar antes de llenarse = golpe fuerte normal.
## Soltar con la carga llena = ataque cargado. Te mueves despacio mientras cargas.
## Dash y salto cortan la carga en cualquier momento.

var _held: float = 0.0
var _full: bool = false


func enter(_previous: State) -> void:
	_held = 0.0
	_full = false
	player.sprite.speed_scale = 1.0


func exit() -> void:
	player.sprite.modulate = Color.WHITE


func physics_update(delta: float) -> void:
	if try_dash() or try_jump():
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


## Placeholder de feedback: se tiñe al cargar y parpadea cuando está lleno.
func _update_visual() -> void:
	var ratio := clampf(_held / player.charge_time, 0.0, 1.0)
	if ratio >= 1.0:
		_full = true
		var blink := fmod(_held - player.charge_time, player.charge_blink_period) < player.charge_blink_period / 2.0
		player.sprite.modulate = player.charge_full_color if blink else player.charge_color
	else:
		player.sprite.modulate = Color.WHITE.lerp(player.charge_color, ratio)
