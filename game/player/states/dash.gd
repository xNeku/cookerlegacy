extends PlayerState
## Dash: estallido corto e invulnerable en la dirección del movimiento
## (o hacia donde mira si está quieto). Si pulsas atacar durante el dash,
## el golpe sale nada más acabar (dash-strike).

var _time: float = 0.0
var _dir: Vector2 = Vector2.DOWN
## Estado al que ir al acabar si se pulsó atacar durante el dash ("" = ninguno).
var _queued_state: StringName = &""


func enter(_previous: State) -> void:
	_time = 0.0
	_queued_state = &""
	var input := player.get_move_input()
	_dir = input.normalized() if not input.is_zero_approx() else player.facing
	player.update_facing(_dir)
	player.velocity = _dir * player.dash_speed
	player.start_dash_cooldown()
	player.invulnerable = true
	player.sprite.speed_scale = 1.0
	player.sprite.modulate = player.dash_color


func exit() -> void:
	player.invulnerable = false
	player.sprite.modulate = Color.WHITE


func physics_update(delta: float) -> void:
	_time += delta
	if Input.is_action_just_pressed("attack_light"):
		_queued_state = &"LightAttack"
	elif Input.is_action_just_pressed("attack_heavy"):
		_queued_state = &"Charge"

	player.move_and_slide()
	player.play_animation("dash", "walk")

	if _time >= player.dash_duration:
		# Sale a velocidad de andar como mucho, para que no siga resbalando.
		player.velocity = player.velocity.limit_length(player.max_speed)
		if _queued_state != &"":
			machine.change_to(_queued_state)
		else:
			machine.change_to(&"Idle" if player.get_move_input().is_zero_approx() else &"Move")
