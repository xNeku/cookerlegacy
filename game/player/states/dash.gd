extends PlayerState
## Dash: estallido corto e invulnerable en la dirección del movimiento
## (o hacia donde mira si está quieto). Gasta una carga. Deja estela de fantasmas y polvo.
## - Saltar durante el dash lo corta y salta conservando la velocidad (salto largo).
## - Atacar durante el dash: el golpe sale nada más acabar (dash-strike).
## - Otro dash pulsado durante este sale al acabar (si quedan cargas).
## - En el aire, la gravedad se para mientras dura (si dash_suspends_gravity).

var _time: float = 0.0
var _ghost_time: float = 0.0
var _dir: Vector2 = Vector2.DOWN


func enter(_previous: State) -> void:
	_time = 0.0
	_ghost_time = 0.0
	var input := player.get_move_input()
	_dir = input.normalized() if not input.is_zero_approx() else player.facing
	player.update_facing(_dir)
	player.planar_velocity = _dir * player.dash_speed
	player.use_dash_charge()
	player.invulnerable = true
	# Atraviesa enemigos (capa 3) durante el dash: un grupo no te encierra.
	player.set_collision_mask_value(3, false)
	player.gravity_paused = player.dash_suspends_gravity and player.is_airborne()
	player.sprite.speed_scale = 1.0
	player.sprite_fx.set_tint(player.dash_color, 0.45)
	player.play_animation("dash", "walk", true)
	if not player.is_airborne():
		player.spawn_dust(true)
	player.spawn_afterimage(player.dash_color)


func exit() -> void:
	player.invulnerable = false
	player.set_collision_mask_value(3, true)
	player.gravity_paused = false
	player.sprite_fx.set_tint(player.dash_color, 0.0)


func physics_update(delta: float) -> void:
	_time += delta
	# Salto en mitad del dash: se corta ya y se lleva la velocidad del dash.
	if try_jump():
		return

	player.move_and_slide()
	player.play_animation("dash", "walk")
	_ghost_time += delta
	if _ghost_time >= player.afterimage_interval:
		_ghost_time = 0.0
		player.spawn_afterimage(player.dash_color)

	if _time >= player.dash_duration:
		# Sale a velocidad de andar como mucho en el suelo; en el aire conserva más.
		if not player.is_airborne():
			player.planar_velocity = player.planar_velocity.limit_length(player.max_speed)
		# Lo que se pulsó durante el dash sale ahora (dash-strike, dash-dash...).
		if try_dash() or try_spin() or try_attack():
			return
		machine.change_to(player.free_state())
