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

@export_group("Animación")
## La animación de andar va más rápida o lenta según la velocidad real (útil con stick a medias).
@export var scale_walk_with_speed: bool = true
## Velocidad mínima de reproducción de andar, para que a paso lento no parezca congelado.
@export_range(0.1, 1.0) var min_walk_anim_speed: float = 0.4

## Dirección cardinal a la que mira: DOWN, UP, LEFT o RIGHT.
var facing: Vector2 = Vector2.DOWN

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var state_machine: StateMachine = %StateMachine
@onready var hitbox: Hitbox = %Hitbox


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
