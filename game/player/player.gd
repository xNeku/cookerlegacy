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
## Tiempo de espera tras acabar un dash para poder hacer otro.
@export var dash_cooldown: float = 0.3
## Tinte durante el dash (placeholder hasta que haya estela/animación).
@export var dash_color: Color = Color(0.6, 0.85, 1.0, 0.7)

@export_group("Salto")
## Altura máxima del salto en píxeles.
@export var jump_height: float = 18.0
## Duración total del salto en segundos.
@export var jump_duration: float = 0.45
## Control en el aire (1 = como en el suelo, 0 = sin control).
@export_range(0.0, 1.0) var jump_air_control: float = 1.0
## Tamaño mínimo de la sombra en lo alto del salto.
@export_range(0.1, 1.0) var shadow_min_scale: float = 0.6

@export_group("Animación")
## La animación de andar va más rápida o lenta según la velocidad real (útil con stick a medias).
@export var scale_walk_with_speed: bool = true
## Velocidad mínima de reproducción de andar, para que a paso lento no parezca congelado.
@export_range(0.1, 1.0) var min_walk_anim_speed: float = 0.4

## Dirección cardinal a la que mira: DOWN, UP, LEFT o RIGHT.
var facing: Vector2 = Vector2.DOWN
## Si está activo, no recibe daño (dash). Lo leerá su Hurtbox cuando la tenga.
var invulnerable: bool = false
## Altura sobre el suelo (salto). El cuerpo no se mueve; sube el sprite.
var height: float = 0.0

## Momento (segundos de juego) a partir del cual se puede volver a hacer dash.
var _dash_ready_at: float = 0.0

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var state_machine: StateMachine = %StateMachine
@onready var hitbox: Hitbox = %Hitbox
@onready var shadow: Sprite2D = %Shadow

## Posición original del sprite: la altura se suma sobre ella.
@onready var _sprite_base_position: Vector2 = sprite.position


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
	return _now() >= _dash_ready_at


func start_dash_cooldown() -> void:
	_dash_ready_at = _now() + dash_duration + dash_cooldown


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


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
