extends PlayerState
## Ataque de un combo. El mismo script sirve para □, △ y el cargado:
## cada nodo dice en el Inspector qué combo usa y con qué botón encadena.
## Pulsar antes de `chain_from` se guarda y el siguiente golpe sale justo al llegar.
## Dash y salto lo cortan desde `cancel_from` del golpe. En el aire, se sigue cayendo.

enum ComboSlot { LIGHT, HEAVY, CHARGED }

## Qué combo del Player usa este nodo.
@export var combo_slot: ComboSlot = ComboSlot.LIGHT
## Botón que encadena el siguiente golpe de este mismo combo.
@export var input_action: StringName = &"attack_light"
## Botón que, pulsado durante el golpe, salta a otro estado en el punto de encadenado (□ → △...).
## Vacío = sin salto.
@export var switch_action: StringName = &""
## Estado al que salta con `switch_action`.
@export var switch_state: StringName = &""

var _combo: ComboData
var _attack: AttackData
var _time: float = 0.0
var _buffered: bool = false
var _switch_buffered: bool = false
## Golpe en el que vamos (-1 = ninguno) y cuándo se pierde el combo si no se sigue.
var _step: int = -1
var _expires_at: float = 0.0


func enter(_previous: State) -> void:
	_combo = _get_combo()
	_begin(_next_step())


func exit() -> void:
	player.hitbox.set_active(false)


func physics_update(delta: float) -> void:
	_time += delta
	# Dash y salto cortan el golpe desde `cancel_from` (por defecto, desde el primer frame).
	if _time >= _attack.cancel_from and (try_dash() or try_jump()):
		_finish()
		return
	# Solo se "gasta" la pulsación si hay siguiente golpe; si no, se queda en el buffer
	# y al acabar empieza un combo nuevo.
	if _has_next_step() and player.consume_action(input_action):
		_buffered = true
	if switch_action != &"" and player.consume_action(switch_action):
		_switch_buffered = true

	player.hitbox.set_active(_time >= _attack.hit_start and _time < _attack.hit_end)

	var input := player.get_move_input()
	if _time >= _attack.lunge_time:
		player.steer(input, _attack.move_speed_multiplier, delta)
	player.move_and_slide()
	# Sin animación de ataque (placeholder): si te mueves pegando, anda en vez de patinar.
	player.play_animation(_attack.animation, "idle" if input.is_zero_approx() else "walk")

	if _time >= _attack.chain_from:
		if _buffered and _has_next_step():
			_begin(_next_step())
			return
		if _switch_buffered:
			_finish()
			# △ en el aire no carga: va directo al golpe fuerte.
			var target := switch_state
			if target == &"Charge" and player.is_airborne():
				target = &"HeavyAttack"
			machine.change_to(target)
			return

	if _time >= _attack.duration:
		_finish()
		# Si quedó algo pulsado justo al final, sale ya; si no, a estado libre (o al aire).
		if try_start_action():
			return
		machine.change_to(player.free_state())


func _begin(step: int) -> void:
	_attack = _combo.attacks[step]
	_time = 0.0
	_buffered = false
	_switch_buffered = false
	var dir := player.get_attack_direction()
	player.update_facing(dir)
	player.sprite.speed_scale = 1.0
	player.hitbox.set_active(false)
	player.hitbox.configure(_attack, dir)
	# Conserva parte de la inercia y suma el pasito: así andar y pegar no frena en seco.
	player.velocity = player.velocity * player.attack_momentum_keep + dir * _attack.lunge_speed


## Qué golpe toca: sigue el combo si no ha caducado; si no, vuelve al primero.
func _next_step() -> int:
	var continuing := _step >= 0 and (_expires_at < 0.0 or _now() <= _expires_at)
	_step = _step + 1 if continuing else 0
	if _step >= _combo.attacks.size():
		_step = 0
	_expires_at = -1.0  # mientras se ataca, el combo no caduca
	return _step


func _has_next_step() -> bool:
	return _step + 1 < _combo.attacks.size()


## Al acabar sin encadenar: abre la ventana para seguir el combo, salvo tras el último golpe.
func _finish() -> void:
	if _has_next_step():
		_expires_at = _now() + _combo.reset_time
	else:
		_step = -1


func _get_combo() -> ComboData:
	match combo_slot:
		ComboSlot.HEAVY:
			return player.heavy_combo
		ComboSlot.CHARGED:
			return player.charged_attack
	return player.light_combo


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
