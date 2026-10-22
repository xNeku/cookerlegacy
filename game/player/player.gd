class_name Player
extends CharacterBody2D
## El cocinero. Aquí viven sus datos y acciones básicas (moverse, girarse, animar).
## Qué hace en cada momento lo deciden los estados de %StateMachine.

@export_group("Movimiento")
## Velocidad máxima en píxeles/segundo con el stick al fondo.
@export var max_speed: float = 110.0
## Cuánto tarda en llegar a la velocidad máxima (px/s²). Más alto = más reactivo.
@export var acceleration: float = 900.0
## Cuánto frena al soltar (px/s²). Más alto = para en seco.
@export var friction: float = 1100.0

@export_group("Orientación")
## En diagonales casi perfectas, cuánto tiene que dominar un eje para cambiar de lado/arriba/abajo.
## Evita que la animación parpadee entre dos direcciones. 0 = sin margen.
@export_range(0.0, 0.5) var facing_hysteresis: float = 0.15

@export_group("Combate")
## Combos del arma (en Fase 4 vendrán del arma equipada).
## □ / clic izquierdo.
@export var light_combo: ComboData
## △ / clic derecho, tocando.
@export var heavy_combo: ComboData
## △ / clic derecho, manteniendo hasta cargar del todo (un solo golpe).
@export var charged_attack: ComboData
## Parte de la velocidad que se conserva al empezar un golpe (0 = frena en seco, 1 = toda).
@export_range(0.0, 1.0) var attack_momentum_keep: float = 0.4

@export_group("Carga (△ mantenido)")
## Segundos manteniendo △ hasta tener la carga llena.
@export var charge_time: float = 0.6
## Velocidad mientras cargas (1 = normal).
@export_range(0.0, 1.0) var charge_move_multiplier: float = 0.35
## Tinte al ir cargando (placeholder hasta que haya efecto de carga).
@export var charge_color: Color = Color(1.0, 0.6, 0.25)
## Destello cuando la carga está llena.
@export var charge_full_color: Color = Color(2.0, 2.0, 2.0)
## Velocidad del parpadeo con la carga llena (segundos por ciclo).
@export var charge_blink_period: float = 0.12

@export_group("Dash")
## Velocidad del dash (px/s).
@export var dash_speed: float = 380.0
## Duración del dash en segundos (distancia ≈ velocidad × duración).
@export var dash_duration: float = 0.14
## Dashes seguidos que puedes hacer antes de tener que esperar (como en Hades).
@export_range(1, 5) var dash_max_charges: int = 2
## Segundos que tarda en recuperarse una carga de dash.
@export var dash_recharge_time: float = 0.45
## Durante un dash en el aire, la gravedad se para (el dash "flota").
@export var dash_suspends_gravity: bool = true
## Tinte durante el dash (placeholder hasta que haya estela/animación).
@export var dash_color: Color = Color(0.6, 0.85, 1.0, 0.7)

@export_group("Salto")
## Altura máxima del salto en píxeles.
@export var jump_height: float = 18.0
## Duración total del salto en segundos.
@export var jump_duration: float = 0.45
## Velocidad máxima controlando en el aire (1 = como en el suelo).
@export_range(0.0, 1.0) var jump_air_control: float = 1.0
## Aceleración en el aire (px/s²). Más baja que en el suelo = conserva la inercia
## (dash → salto da un salto largo).
@export var air_acceleration: float = 450.0
## Frenado en el aire sin input (px/s²).
@export var air_friction: float = 250.0
## Tamaño mínimo de la sombra en lo alto del salto.
@export_range(0.1, 1.0) var shadow_min_scale: float = 0.6

@export_group("Recibir daño")
## Tiempo aturdido al recibir un golpe (s). Se puede cortar con dash.
@export var hurt_time: float = 0.2
## Desde cuándo el dash corta el aturdimiento (s).
@export var hurt_dash_cancel_from: float = 0.08
## Invulnerabilidad tras recibir un golpe (s), para que un grupo no te encadene.
@export var hurt_iframes: float = 0.6
## Parpadeo durante esa invulnerabilidad (s por ciclo).
@export var hurt_blink_period: float = 0.08
## Congelado al recibir un golpe (s).
@export var hurt_hitstop: float = 0.06
## Temblor de cámara al recibir un golpe (px).
@export var hurt_shake: float = 3.0
## Por encima de esta altura (px) el salto esquiva los ataques a ras de suelo.
@export var jump_dodge_height: float = 8.0

@export_group("Fluidez")
## Si pulsas una acción un poco antes de poder hacerla, se guarda este tiempo (s)
## y sale en cuanto se pueda. Es lo que hace que las cadenas encajen.
@export var input_buffer_time: float = 0.12

@export_group("Animación")
## La animación de andar va más rápida o lenta según la velocidad real (útil con stick a medias).
@export var scale_walk_with_speed: bool = true
## Velocidad mínima de reproducción de andar, para que a paso lento no parezca congelado.
@export_range(0.1, 1.0) var min_walk_anim_speed: float = 0.4

## Dirección cardinal a la que mira: DOWN, UP, LEFT o RIGHT.
var facing: Vector2 = Vector2.DOWN
## Invulnerable por dash. (La Hurtbox también ignora golpes con i-frames y en lo alto del salto.)
var invulnerable: bool = false
## Altura sobre el suelo (salto). El cuerpo no se mueve; sube el sprite.
## Va por su cuenta (gravedad propia), así se puede pegar o hacer dash en el aire.
var height: float = 0.0
## Si está activo, la gravedad no actúa (dash en el aire).
var gravity_paused: bool = false

## Acciones que pasan por el buffer de input.
const BUFFERED_ACTIONS: Array[StringName] = [&"attack_light", &"attack_heavy", &"dash", &"jump"]

## Reloj de juego (s): avanza con el tiempo del juego, así que se para en el hitstop.
## El buffer y los combos miden con este, no con el reloj real.
var _clock: float = 0.0
var _vertical_speed: float = 0.0
## Invulnerabilidad que queda tras recibir un golpe (s).
var _iframes_left: float = 0.0
var _dash_charges: int = 0
var _dash_recharge: float = 0.0
## Momento (reloj de juego) en que se pulsó cada acción y aún no se ha usado.
var _buffer: Dictionary = {}

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var state_machine: StateMachine = %StateMachine
@onready var hitbox: Hitbox = %Hitbox
@onready var shadow: Sprite2D = %Shadow
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var health: Health = %Health

## Posición original del sprite: la altura se suma sobre ella.
@onready var _sprite_base_position: Vector2 = sprite.position


func _ready() -> void:
	add_to_group(&"player")
	_dash_charges = dash_max_charges
	hurtbox.hit_received.connect(_on_hit_received)


# Corre antes que la StateMachine (los padres procesan antes que los hijos).
func _physics_process(delta: float) -> void:
	_clock += delta
	_update_dash_charges(delta)
	_update_height(delta)
	_update_invulnerability(delta)


## True si `action` se pulsó hace menos de `input_buffer_time` y no se ha usado.
## La "gasta": solo la usa un estado.
func consume_action(action: StringName) -> bool:
	if not _buffer.has(action):
		return false
	var fresh: bool = _clock - _buffer[action] <= input_buffer_time
	_buffer.erase(action)
	return fresh


## Como consume_action pero sin gastarla (para mirar sin usar).
func has_buffered(action: StringName) -> bool:
	return _buffer.has(action) and _clock - _buffer[action] <= input_buffer_time


## Tiempo de juego (s). Se para durante el hitstop.
func game_time() -> float:
	return _clock


## Estado "libre" al que volver tras una acción: en el aire, Jump; si no, Idle o Move.
func free_state() -> StringName:
	if is_airborne():
		return &"Jump"
	return &"Idle" if get_move_input().is_zero_approx() else &"Move"


## Vector del stick/WASD. Longitud 0..1 (analógico real; en teclado la diagonal se normaliza).
func get_move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


## Acelera hacia `direction`. Con el stick a medias, la velocidad objetivo es menor.
func accelerate_towards(direction: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)


func apply_friction(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


## Moverse a velocidad reducida (al pegar, al cargar...). Sin input, frena.
func steer(direction: Vector2, speed_multiplier: float, delta: float) -> void:
	if direction.is_zero_approx():
		apply_friction(delta)
	else:
		velocity = velocity.move_toward(direction * max_speed * speed_multiplier, acceleration * delta)


## Actualiza `facing` a la dirección cardinal más cercana a `direction`.
func update_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	var ax := absf(direction.x)
	var ay := absf(direction.y)
	var facing_is_horizontal := facing.x != 0.0
	# Si la diferencia entre ejes es pequeña, mantenemos el eje actual (histéresis).
	if absf(ax - ay) < facing_hysteresis * direction.length():
		if facing_is_horizontal and direction.x != 0.0:
			facing = Vector2(signf(direction.x), 0.0)
			return
		if not facing_is_horizontal and direction.y != 0.0:
			facing = Vector2(0.0, signf(direction.y))
			return
	if ax > ay:
		facing = Vector2(signf(direction.x), 0.0)
	else:
		facing = Vector2(0.0, signf(direction.y))


func can_dash() -> bool:
	return _dash_charges > 0


func use_dash_charge() -> void:
	_dash_charges -= 1


func is_airborne() -> bool:
	return height > 0.0 or _vertical_speed > 0.0


func can_jump() -> bool:
	return not is_airborne()


## Despega. La altura y la caída las lleva el propio Player (_update_height).
func jump() -> void:
	# Con altura h y duración T: v0 = 4h/T y gravedad = 8h/T² dan una parábola exacta.
	_vertical_speed = 4.0 * jump_height / jump_duration


## Moverse en el aire: acelera menos que en el suelo para conservar la inercia.
func air_steer(direction: Vector2, delta: float) -> void:
	if direction.is_zero_approx():
		velocity = velocity.move_toward(Vector2.ZERO, air_friction * delta)
	else:
		velocity = velocity.move_toward(direction * max_speed * jump_air_control, air_acceleration * delta)


## Sube el sprite `value` píxeles y encoge la sombra en proporción.
func set_height(value: float) -> void:
	height = value
	sprite.position = _sprite_base_position + Vector2(0.0, -height)
	var ratio := clampf(height / jump_height, 0.0, 1.0) if jump_height > 0.0 else 0.0
	shadow.scale = Vector2.ONE * lerpf(1.0, shadow_min_scale, ratio)


## Dirección del ataque. Con ratón: hacia el cursor. Con mando: hacia el stick,
## o hacia donde mira si el stick está suelto. InputMode decide cuál se usa.
func get_attack_direction() -> Vector2:
	if InputMode.is_gamepad():
		var stick := get_move_input()
		return stick.normalized() if not stick.is_zero_approx() else facing
	var to_mouse := get_global_mouse_position() - hitbox.global_position
	return to_mouse.normalized() if not to_mouse.is_zero_approx() else facing


## Reproduce "<base>_down/up/side" según `facing`. El lado izquierdo es el derecho en espejo.
## Si esa animación no existe todavía (falta arte), usa `fallback`.
func play_animation(base: String, fallback: String = "") -> void:
	var suffix := "side" if facing.x != 0.0 else ("up" if facing.y < 0.0 else "down")
	sprite.flip_h = facing.x < 0.0
	var anim := base + "_" + suffix
	if not sprite.sprite_frames.has_animation(anim) and fallback != "":
		anim = fallback + "_" + suffix
	if sprite.animation != anim:
		sprite.play(anim)



## Ajusta la velocidad de la animación de andar a lo rápido que se mueve.
func update_walk_anim_speed() -> void:
	if not scale_walk_with_speed:
		sprite.speed_scale = 1.0
		return
	var ratio := velocity.length() / max_speed
	sprite.speed_scale = clampf(ratio, min_walk_anim_speed, 1.0)


func _on_hit_received(hb: Hitbox) -> void:
	velocity = hb.direction * hb.knockback
	_iframes_left = hurt_iframes
	HitStop.freeze(hurt_hitstop)
	get_tree().call_group(&"game_camera", &"shake", hurt_shake, 0.15)
	state_machine.change_to(&"Hurt")


func _update_invulnerability(delta: float) -> void:
	_iframes_left = maxf(_iframes_left - delta, 0.0)
	hurtbox.invulnerable = invulnerable or _iframes_left > 0.0 or height > jump_dodge_height
	# Parpadeo con self_modulate (no pisa el tinte del dash o la carga, que usan modulate).
	if _iframes_left > 0.0:
		var on := fmod(_iframes_left, hurt_blink_period) < hurt_blink_period / 2.0
		sprite.self_modulate.a = 0.35 if on else 1.0
	else:
		sprite.self_modulate.a = 1.0


# Las pulsaciones se apuntan en cuanto llegan (no una vez por frame de física):
# así no se pierde ninguna, ni siquiera un toque rapidísimo o durante el hitstop.
func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	for action in BUFFERED_ACTIONS:
		if event.is_action_pressed(action):
			_buffer[action] = _clock


func _update_dash_charges(delta: float) -> void:
	if _dash_charges >= dash_max_charges:
		_dash_recharge = 0.0
		return
	_dash_recharge += delta
	if _dash_recharge >= dash_recharge_time:
		_dash_recharge = 0.0
		_dash_charges += 1


func _update_height(delta: float) -> void:
	if not is_airborne() or gravity_paused:
		return
	var gravity := 8.0 * jump_height / (jump_duration * jump_duration)
	_vertical_speed -= gravity * delta
	var new_height := height + _vertical_speed * delta
	if new_height <= 0.0:
		new_height = 0.0
		_vertical_speed = 0.0
	set_height(new_height)

