extends PlayerState
## Dash: estallido corto e invulnerable en la dirección del movimiento
## (o hacia donde mira si está quieto). Gasta una carga.
## - Saltar durante el dash lo corta y salta conservando la velocidad (salto largo).
## - Atacar durante el dash: el golpe sale nada más acabar (dash-strike).
## - Otro dash pulsado durante este sale al acabar (si quedan cargas).
## - En el aire, la gravedad se para mientras dura (si dash_suspends_gravity).

var _time: float = 0.0
var _dir: Vector2 = Vector2.DOWN


func enter(_previous: State) -> void:
	_time = 0.0
	var input := player.get_move_input()
	_dir = input.normalized() if not input.is_zero_approx() else player.facing
	player.update_facing(_dir)
	player.velocity = _dir * player.dash_speed
	player.use_dash_charge()
	player.invulnerable = true
	player.gravity_paused = player.dash_suspends_gravity and player.is_airborne()
	player.sprite.speed_scale = 1.0
	player.sprite.modulate = player.dash_color


func exit() -> void:
	player.invulnerable = false
	player.gravity_paused = false
	player.sprite.modulate = Color.WHITE


func physics_update(delta: float) -> void:
	_time += delta
	# Salto en mitad del dash: se corta ya y se lleva la velocidad del dash.
	if try_jump():
		return

	player.move_and_slide()
	player.play_animation("dash", "walk")

	if _time >= player.dash_duration:
		# Sale a velocidad de andar como mucho en el suelo; en el aire conserva más.
		if not player.is_airborne():
			player.velocity = player.velocity.limit_length(player.max_speed)
		# Lo que se pulsó durante el dash sale ahora (dash-strike, dash-dash...).
		if try_dash() or try_attack():
			return
		machine.change_to(player.free_state())
