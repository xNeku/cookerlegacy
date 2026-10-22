extends PlayerState
## Golpe giratorio (R1 / Q): gira con el arma dando golpes a todo lo que hay alrededor
## y empujándolo hacia fuera. Te mueves mientras giras (`move_speed_multiplier` del golpe).
## Si el golpe tiene `multi_hit_interval`, vuelve a golpear cada ese tiempo.
## Dash y salto lo cortan. (En Fase 5 este mismo giro cosechará.)

const FACINGS: Array[Vector2] = [Vector2.DOWN, Vector2.RIGHT, Vector2.UP, Vector2.LEFT]

var _time: float = 0.0
var _since_hit: float = 0.0
var _face_index: int = 0
var _face_time: float = 0.0


func enter(_previous: State) -> void:
	_time = 0.0
	_since_hit = 0.0
	_face_time = 0.0
	_face_index = FACINGS.find(player.facing)
	player.start_spin_cooldown()
	player.sprite.speed_scale = 1.0
	player.hitbox.configure(player.spin_attack, player.facing)
	player.hitbox.set_active(false)


func exit() -> void:
	player.hitbox.set_active(false)


func physics_update(delta: float) -> void:
	var attack := player.spin_attack
	_time += delta
	if _time >= attack.cancel_from and (try_dash() or try_jump()):
		return

	_update_hits(attack, delta)

	var input := player.get_move_input()
	player.steer(input, attack.move_speed_multiplier, delta)
	player.move_and_slide()
	_spin_visual(delta)

	if _time >= attack.duration:
		player.hitbox.set_active(false)
		if try_start_action():
			return
		machine.change_to(player.free_state())


## Activa el área en la ventana de daño. Con multi-golpe la apaga un frame cada
## `multi_hit_interval` para que vuelva a "entrar" en los enemigos y golpee otra vez.
func _update_hits(attack: AttackData, delta: float) -> void:
	var in_window := _time >= attack.hit_start and _time < attack.hit_end
	if not in_window:
		player.hitbox.set_active(false)
		return
	_since_hit += delta
	if attack.multi_hit_interval > 0.0 and _since_hit >= attack.multi_hit_interval:
		_since_hit = 0.0
		player.hitbox.set_active(false)
		return
	player.hitbox.set_active(true)


## Placeholder: sin animación de giro, recorre las 4 direcciones muy rápido.
func _spin_visual(delta: float) -> void:
	if player.sprite.sprite_frames.has_animation(&"spin_down"):
		player.play_animation("spin")
		return
	_face_time += delta
	if _face_time >= player.spin_face_period:
		_face_time = 0.0
		_face_index = (_face_index + 1) % FACINGS.size()
		player.facing = FACINGS[_face_index]
	player.play_animation("idle")
