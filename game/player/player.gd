class_name Player
extends CharacterBody3D
## El cocinero. Aquí viven sus datos y acciones básicas (moverse, girarse, animar, efectos).
## Qué hace en cada momento lo deciden los estados de %StateMachine.
## El movimiento se piensa en el plano del suelo (Vector2, ver Flat); el salto es altura real.
## Unidades: metros (32 px de arte = 1 m).

## Se queda sin vida (ya en el estado Dead).
signal died
## Llega al final de un `walk_path()` (paseo automático).
signal scripted_walk_finished

## Modo dios: recibe golpes pero no muere (la sala de pruebas lo usa).
@export var god_mode: bool = false

@export_group("Movimiento")
## Velocidad máxima (m/s) con el stick al fondo.
@export var max_speed: float = 3.45
## Cuánto tarda en llegar a la velocidad máxima (m/s²). Más alto = más reactivo.
@export var acceleration: float = 28.0
## Cuánto frena al soltar (m/s²). Más alto = para en seco.
@export var friction: float = 34.0

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

@export_group("Golpe giratorio (R1 / Q)")
## El golpe del giro (área circular, multi-golpe). En Fase 4 vendrá del arma.
@export var spin_attack: AttackData
## Espera entre giros (s), contada desde que empieza uno.
@export var spin_cooldown: float = 1.2

@export_group("Carga (△ mantenido)")
## Segundos manteniendo △ hasta tener la carga llena.
@export var charge_time: float = 0.6
## Velocidad mientras cargas (1 = normal).
@export_range(0.0, 1.0) var charge_move_multiplier: float = 0.35
## Brillo del cocinero al ir cargando.
@export var charge_color: Color = Color(1.0, 0.55, 0.2)
## Temblor del sprite con la carga llena (m).
@export var charge_full_shake: float = 0.02

@export_group("Dash")
## Velocidad del dash (m/s).
@export var dash_speed: float = 11.9
## Duración del dash en segundos (distancia ≈ velocidad × duración).
@export var dash_duration: float = 0.14
## Dashes seguidos que puedes hacer antes de tener que esperar (como en Hades).
@export_range(1, 5) var dash_max_charges: int = 2
## Segundos que tarda en recuperarse una carga de dash.
@export var dash_recharge_time: float = 0.45
## Durante un dash en el aire, la gravedad se para (el dash "flota").
@export var dash_suspends_gravity: bool = true
## Brillo del cocinero durante el dash.
@export var dash_color: Color = Color(0.45, 0.75, 1.0)

@export_group("Salto")
## Altura máxima del salto (m).
@export var jump_height: float = 0.56
## Duración total del salto en segundos.
@export var jump_duration: float = 0.45
## Velocidad máxima controlando en el aire (1 = como en el suelo).
@export_range(0.0, 1.0) var jump_air_control: float = 1.0
## Aceleración en el aire (m/s²). Más baja que en el suelo = conserva la inercia
## (dash → salto da un salto largo).
@export var air_acceleration: float = 14.0
## Frenado en el aire sin input (m/s²).
@export var air_friction: float = 7.8
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
## Temblor de cámara al recibir un golpe (m).
@export var hurt_shake: float = 0.1
## Por encima de esta altura (m) el salto esquiva los ataques a ras de suelo.
@export var jump_dodge_height: float = 0.25

@export_group("Morir")
## Congelado al caer (s).
@export var death_hitstop: float = 0.25
## Temblor de cámara al caer (m).
@export var death_shake: float = 0.3
## Color al que se apaga tumbado.
@export var death_color: Color = Color(0.25, 0.22, 0.3)

@export_group("Fluidez")
## Si pulsas una acción un poco antes de poder hacerla, se guarda este tiempo (s)
## y sale en cuanto se pueda. Es lo que hace que las cadenas encajen.
@export var input_buffer_time: float = 0.12

@export_group("Efectos")
## Polvo al correr (un puff cada `dust_step_distance` metros).
@export var dust_scene: PackedScene
## Polvo grande (empezar un dash, aterrizar).
@export var dust_burst_scene: PackedScene
## Fantasma que deja el dash.
@export var afterimage_scene: PackedScene
## Onda expansiva (golpes con `vfx_ring`, carga llena).
@export var ring_scene: PackedScene
@export var dust_step_distance: float = 0.9
## Cada cuánto deja un fantasma durante el dash (s).
@export var afterimage_interval: float = 0.022
## Altura de caída (m) a partir de la que aterrizar levanta polvo y tiembla un poco.
@export var land_fx_height: float = 0.3

@export_group("Animación")
## La animación de andar va más rápida o lenta según la velocidad real (útil con stick a medias).
@export var scale_walk_with_speed: bool = true
## Velocidad mínima de reproducción de andar, para que a paso lento no parezca congelado.
@export_range(0.1, 1.0) var min_walk_anim_speed: float = 0.4

## Dirección cardinal a la que mira (en el suelo): DOWN, UP, LEFT o RIGHT.
var facing: Vector2 = Vector2.DOWN
## Invulnerable por dash. (La Hurtbox también ignora golpes con i-frames y en lo alto del salto.)
var invulnerable: bool = false
## Altura sobre el suelo (m). La lleva el propio Player con su gravedad.
var height: float = 0.0
## Si está activo, la gravedad no actúa (dash en el aire).
var gravity_paused: bool = false
## Velocidad en el plano del suelo (los estados trabajan con esta).
var planar_velocity: Vector2:
	get:
		return Vector2(velocity.x, velocity.z)
	set(value):
		velocity.x = value.x
		velocity.z = value.y
## Posición en el plano del suelo.
var ground_position: Vector2:
	get:
		return Flat.of(global_position)

## Acciones que pasan por el buffer de input.
const BUFFERED_ACTIONS: Array[StringName] = [&"attack_light", &"attack_heavy", &"dash", &"jump", &"skill_1", &"interact"]

## Puntos que le quedan por recorrer en un paseo automático (estado Scripted).
var scripted_points: Array[Vector3] = []
## Velocidad del paseo automático (1 = velocidad máxima andando).
var scripted_speed: float = 0.7

## Reloj de juego (s): avanza con el tiempo del juego, así que se para en el hitstop.
## El buffer y los combos miden con este, no con el reloj real.
var _clock: float = 0.0
var _vertical_speed: float = 0.0
var _max_air_height: float = 0.0
## Momento (reloj de juego) en que se puede volver a girar.
var _spin_ready_at: float = 0.0
## Invulnerabilidad que queda tras recibir un golpe (s).
var _iframes_left: float = 0.0
var _dash_charges: int = 0
var _dash_recharge: float = 0.0
var _dust_distance: float = 0.0
## Momento (reloj de juego) en que se pulsó cada acción y aún no se ha usado.
var _buffer: Dictionary = {}
## Cosas con las que puede interactuar ahora mismo (está dentro de su área).
var _interactables: Array[Interactable] = []

@onready var sprite: AnimatedSprite3D = %Sprite
@onready var sprite_fx: SpriteFX = %SpriteFX
@onready var state_machine: StateMachine = %StateMachine
@onready var hitbox: Hitbox = %Hitbox
@onready var shadow: Decal = %Shadow
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var health: Health = %Health
@onready var charge_particles: CPUParticles3D = %ChargeParticles

@onready var _shadow_base_scale: Vector3 = shadow.scale
@onready var _sprite_base_position: Vector3 = sprite.position


func _ready() -> void:
	add_to_group(&"player")
	_dash_charges = dash_max_charges
	health.immortal = god_mode
	hurtbox.hit_received.connect(_on_hit_received)
	health.died.connect(_on_died)


# Corre antes que la StateMachine (los padres procesan antes que los hijos).
func _physics_process(delta: float) -> void:
	_clock += delta
	velocity.y = 0.0
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
	planar_velocity = planar_velocity.move_toward(direction * max_speed, acceleration * delta)


func apply_friction(delta: float) -> void:
	planar_velocity = planar_velocity.move_toward(Vector2.ZERO, friction * delta)


## Moverse a velocidad reducida (al pegar, al cargar...). Sin input, frena.
func steer(direction: Vector2, speed_multiplier: float, delta: float) -> void:
	if direction.is_zero_approx():
		apply_friction(delta)
	else:
		planar_velocity = planar_velocity.move_toward(direction * max_speed * speed_multiplier, acceleration * delta)


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


## Cargas de dash disponibles (para el HUD).
func get_dash_charges() -> int:
	return _dash_charges


func can_spin() -> bool:
	return spin_attack != null and _clock >= _spin_ready_at


func start_spin_cooldown() -> void:
	_spin_ready_at = _clock + spin_cooldown


## 0 = listo, 1 = recién usado (para el HUD).
func get_spin_cooldown_ratio() -> float:
	if spin_cooldown <= 0.0:
		return 0.0
	return clampf((_spin_ready_at - _clock) / spin_cooldown, 0.0, 1.0)


func is_airborne() -> bool:
	return height > 0.0 or _vertical_speed > 0.0


func can_jump() -> bool:
	return not is_airborne()


## Despega. La altura y la caída las lleva el propio Player (_update_height).
func jump() -> void:
	# Con altura h y duración T: v0 = 4h/T y gravedad = 8h/T² dan una parábola exacta.
	_vertical_speed = 4.0 * jump_height / jump_duration
	_max_air_height = 0.0
	spawn_dust(true)


## Moverse en el aire: acelera menos que en el suelo para conservar la inercia.
func air_steer(direction: Vector2, delta: float) -> void:
	if direction.is_zero_approx():
		planar_velocity = planar_velocity.move_toward(Vector2.ZERO, air_friction * delta)
	else:
		planar_velocity = planar_velocity.move_toward(direction * max_speed * jump_air_control, air_acceleration * delta)


## Pone al cocinero a `value` metros del suelo y encoge la sombra en proporción.
func set_height(value: float) -> void:
	height = value
	position.y = height
	var ratio := clampf(height / jump_height, 0.0, 1.0) if jump_height > 0.0 else 0.0
	var s := lerpf(1.0, shadow_min_scale, ratio)
	shadow.scale = Vector3(_shadow_base_scale.x * s, _shadow_base_scale.y, _shadow_base_scale.z * s)


## Dirección del ataque (en el suelo). Con ratón: hacia el cursor. Con mando: hacia el stick,
## o hacia donde mira si el stick está suelto. InputMode decide cuál se usa.
func get_attack_direction() -> Vector2:
	if InputMode.is_gamepad():
		var stick := get_move_input()
		return stick.normalized() if not stick.is_zero_approx() else facing
	var point = _mouse_ground_point()
	if point == null:
		return facing
	var to_mouse: Vector2 = Flat.of(point) - ground_position
	return to_mouse.normalized() if not to_mouse.is_zero_approx() else facing


## Reproduce "<base>_down/up/side" según `facing`. El lado izquierdo es el derecho en espejo.
## Si esa animación no existe todavía (falta arte), usa `fallback`.
## `restart` la vuelve a empezar aunque ya se esté reproduciendo (golpes repetidos).
func play_animation(base: String, fallback: String = "", restart: bool = false) -> void:
	var suffix := "side" if facing.x != 0.0 else ("up" if facing.y < 0.0 else "down")
	sprite.flip_h = facing.x < 0.0
	var anim := base + "_" + suffix
	if not sprite.sprite_frames.has_animation(anim) and fallback != "":
		anim = fallback + "_" + suffix
	if sprite.animation != anim or restart:
		sprite.play(anim)
		if restart:
			sprite.set_frame_and_progress(0, 0.0)


## Ajusta la velocidad de la animación de andar a lo rápido que se mueve.
func update_walk_anim_speed() -> void:
	if not scale_walk_with_speed:
		sprite.speed_scale = 1.0
		return
	var ratio := planar_velocity.length() / max_speed
	sprite.speed_scale = clampf(ratio, min_walk_anim_speed, 1.0)


## Desplaza el sprite (temblor) sin mover el cuerpo.
func set_sprite_shake(offset: Vector3) -> void:
	sprite.position = _sprite_base_position + offset


# --- Efectos ---------------------------------------------------------------

## Polvo en los pies. `big` = puff grande (dash, salto, aterrizaje).
func spawn_dust(big: bool = false) -> void:
	var scene := dust_burst_scene if big else dust_scene
	FxSpawner.spawn(self, scene, Vector3(global_position.x, 0.02, global_position.z))


## Llamar cada frame al correr: suelta un puff cada `dust_step_distance` metros.
func track_run_dust(delta: float) -> void:
	if is_airborne():
		return
	_dust_distance += planar_velocity.length() * delta
	if _dust_distance >= dust_step_distance:
		_dust_distance = 0.0
		spawn_dust(false)


## Deja un fantasma del frame actual (estela del dash).
func spawn_afterimage(color: Color) -> void:
	if afterimage_scene == null:
		return
	var ghost := afterimage_scene.instantiate() as AfterimageFx
	ghost.copy_from(sprite, color)
	var parent: Node = get_tree().current_scene if get_tree().current_scene else get_tree().root
	parent.add_child(ghost)
	ghost.global_transform = sprite.global_transform


## Onda expansiva en los pies.
func spawn_ring(color: Color, attack: AttackData = null) -> void:
	FxSpawner.spawn(self, ring_scene, Vector3(global_position.x, 0.03, global_position.z), 0.0, color, attack)


# --- Interactuar y paseos automáticos ------------------------------------------

func add_interactable(target: Interactable) -> void:
	if not _interactables.has(target):
		_interactables.append(target)


func remove_interactable(target: Interactable) -> void:
	_interactables.erase(target)


## La más cercana de las que tiene al lado y están activas (o null).
func get_interactable() -> Interactable:
	var best: Interactable = null
	var best_dist := INF
	for target in _interactables:
		if not is_instance_valid(target) or not target.enabled:
			continue
		var d := global_position.distance_to(target.global_position)
		if d < best_dist:
			best_dist = d
			best = target
	return best


## Camina solo por `points` (sin input). Al acabar emite `scripted_walk_finished`.
func walk_path(points: Array[Vector3], speed: float = 0.7) -> void:
	scripted_points = points.duplicate()
	scripted_speed = speed
	state_machine.change_to(&"Scripted")


## Devuelve el control al jugador tras un paseo automático.
func release_control() -> void:
	scripted_points.clear()
	state_machine.change_to(&"Idle")


func is_dead() -> bool:
	return health.current <= 0.0 and not god_mode


func _on_died() -> void:
	state_machine.change_to(&"Dead")
	died.emit()


func _on_hit_received(hb: Hitbox) -> void:
	planar_velocity = hb.get_knockback_direction(global_position) * hb.knockback
	if is_dead():
		planar_velocity *= 1.6
		return
	_iframes_left = hurt_iframes
	HitStop.freeze(hurt_hitstop)
	get_tree().call_group(&"game_camera", &"shake", hurt_shake, 0.15)
	state_machine.change_to(&"Hurt")


func _update_invulnerability(delta: float) -> void:
	_iframes_left = maxf(_iframes_left - delta, 0.0)
	hurtbox.invulnerable = invulnerable or _iframes_left > 0.0 or height > jump_dodge_height
	# Parpadeo: con alpha scissor, alpha < 0.5 = invisible.
	if _iframes_left > 0.0:
		var on := fmod(_iframes_left, hurt_blink_period) < hurt_blink_period / 2.0
		sprite.modulate.a = 0.3 if on else 1.0
	else:
		sprite.modulate.a = 1.0


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
	_max_air_height = maxf(_max_air_height, new_height)
	if new_height <= 0.0:
		new_height = 0.0
		_vertical_speed = 0.0
		_on_landed()
	set_height(new_height)


func _on_landed() -> void:
	if _max_air_height >= land_fx_height:
		spawn_dust(true)
		get_tree().call_group(&"game_camera", &"shake", 0.03, 0.08)
	_max_air_height = 0.0


## Punto del suelo bajo el ratón (o null si la cámara no lo ve).
func _mouse_ground_point() -> Variant:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return null
	var mouse := get_viewport().get_mouse_position()
	var plane := Plane(Vector3.UP, global_position.y)
	return plane.intersects_ray(cam.project_ray_origin(mouse), cam.project_ray_normal(mouse))
