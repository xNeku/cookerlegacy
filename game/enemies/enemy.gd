class_name Enemy
extends CharacterBody3D
## Enemigo base. Datos en `data` (EnemyData); comportamiento en los estados de %StateMachine:
## Idle → Chase → Windup (aviso) → Attack → Recover, más Hurt, Airborne (levantado), Bones y Dead.
## Cada tipo (rata, esqueleto...) es una escena heredada de enemy.tscn con su .tres y su sprite.
## Se mueve en el plano del suelo (Vector2, ver Flat); unidades en metros.

## Al morir (para loot, contadores, spawners...).
signal died(enemy: Enemy)

@export var data: EnemyData

@export_group("Aviso")
## Brillo del enemigo durante el aviso.
@export var windup_color: Color = Color(1.0, 0.3, 0.25)
## Temblor del sprite durante el aviso (m).
@export var windup_shake: float = 0.03
## Muestra en el suelo el área donde va a pegar mientras avisa.
@export var show_telegraph: bool = true

@export_group("Levantado (knockup)")
## Duración en el aire cuando lo levantan (s).
@export var knockup_duration: float = 0.7
## Tamaño mínimo de la sombra en lo alto.
@export_range(0.1, 1.0) var shadow_min_scale: float = 0.6

@export_group("Muerte")
## Tiempo que tarda en desaparecer al morir (s).
@export var death_time: float = 0.3
## Efecto al morir (humo, trozos...).
@export var death_fx: PackedScene
## Color del efecto de muerte.
@export var death_color: Color = Color(0.85, 0.8, 0.75)
## Polvo al caer tras ser levantado.
@export var land_fx: PackedScene

@export_group("Loot")
## Lo que suelta al morir (sale volando al almacén). Qué y cuánto va en `data.loot`.
@export var loot_drop_scene: PackedScene

## A quién persigue (el cocinero, por el grupo "player").
var target: Node3D
## Hacia dónde mira (solo izquierda/derecha: el sprite se voltea).
var facing: Vector2 = Vector2.RIGHT
## Altura sobre el suelo (cuando lo levantan).
var height: float = 0.0
## Altura del último knockup recibido (la usa el estado Airborne).
var knockup_height: float = 0.0
## Su hueco alrededor del cocinero (ángulo, rad). Cada uno nace con uno distinto.
var surround_angle: float = 0.0
## Si está ahora como montón de huesos (rearmarse).
var is_bones: bool = false
## Viene a por ti aunque estés lejos (los que suelta el HordeDirector en el valle).
var always_chase: bool = false
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

var _next_attack_at: float = 0.0

@onready var sprite: AnimatedSprite3D = %Sprite
@onready var sprite_fx: SpriteFX = %SpriteFX
@onready var shadow: Decal = %Shadow
@onready var hitbox: Hitbox = %Hitbox
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var health: Health = %Health
@onready var state_machine: StateMachine = %StateMachine
@onready var telegraph: MeshInstance3D = %Telegraph
@onready var _sprite_base_position: Vector3 = sprite.position
@onready var _shadow_base_scale: Vector3 = shadow.scale


func _ready() -> void:
	health.max_health = data.max_health
	health.current = data.max_health
	hurtbox.heavy_damage_multiplier = data.heavy_damage_multiplier
	health.died.connect(_on_died)
	hurtbox.hit_received.connect(_on_hit_received)
	surround_angle = randf() * TAU
	target = get_tree().get_first_node_in_group(&"player") as Node3D
	telegraph.visible = false
	# Material propio del aviso (cada enemigo lo llena a su ritmo).
	telegraph.material_override = telegraph.material_override.duplicate()


func distance_to_target() -> float:
	return ground_position.distance_to(Flat.of(target.global_position)) if target else INF


func direction_to_target() -> Vector2:
	return ground_position.direction_to(Flat.of(target.global_position)) if target else facing


## Se mueve hacia `point` (en el suelo) a su velocidad (por `speed_multiplier`).
func move_towards(point: Vector2, delta: float, speed_multiplier: float = 1.0) -> void:
	var dir := ground_position.direction_to(point)
	planar_velocity = planar_velocity.move_toward(dir * data.move_speed * speed_multiplier, data.acceleration * delta)
	face(dir)


func apply_friction(delta: float) -> void:
	planar_velocity = planar_velocity.move_toward(Vector2.ZERO, data.friction * delta)


func face(dir: Vector2) -> void:
	if absf(dir.x) > 0.01:
		facing = Vector2(signf(dir.x), 0.0)
		sprite.flip_h = facing.x < 0.0


## Reproduce `anim`; si no existe (falta arte), `fallback`.
func play_animation(anim: StringName, fallback: StringName = &"idle") -> void:
	var anim_name := anim if sprite.sprite_frames.has_animation(anim) else fallback
	if sprite.animation != anim_name:
		sprite.play(anim_name)


func can_attack() -> bool:
	return _now() >= _next_attack_at


func start_attack_cooldown() -> void:
	_next_attack_at = _now() + data.attack_cooldown + randf() * data.attack_cooldown_random


## Pone al enemigo a `value` m del suelo (knockup) y encoge la sombra.
func set_height(value: float) -> void:
	height = value
	position.y = value
	var ratio := clampf(value / maxf(knockup_height, 0.01), 0.0, 1.0)
	var s := lerpf(1.0, shadow_min_scale, ratio)
	shadow.scale = Vector3(_shadow_base_scale.x * s, _shadow_base_scale.y, _shadow_base_scale.z * s)


## Desplaza el sprite sin mover el cuerpo (temblor del aviso).
func set_sprite_offset(offset: Vector3) -> void:
	sprite.position = _sprite_base_position + offset


## Coloca y llena el aviso en el suelo con el área del ataque en dirección `dir`.
func update_telegraph(dir: Vector2, progress: float) -> void:
	var attack := data.attack
	if not show_telegraph or attack == null:
		return
	telegraph.visible = progress > 0.0
	telegraph.rotation.y = Flat.yaw(dir)
	var size := attack.hitbox_size
	if attack.radial:
		telegraph.scale = Vector3(size.x, 1.0, size.x)
		telegraph.position = Vector3(0.0, telegraph.position.y, 0.0)
	else:
		telegraph.scale = Vector3(size.x, 1.0, size.y)
		# El área está delante, a hitbox_distance (más lo que embiste).
		var reach := attack.hitbox_distance + attack.lunge_speed * attack.lunge_time * 0.5
		var forward := Flat.to3(dir) * reach
		telegraph.position = Vector3(forward.x, telegraph.position.y, forward.z)
	(telegraph.material_override as ShaderMaterial).set_shader_parameter("progress", progress)


func hide_telegraph() -> void:
	telegraph.visible = false


func _on_hit_received(hb: Hitbox) -> void:
	var heavy := hb.attack != null and hb.attack.is_heavy
	var resistance := data.heavy_knockback_resistance if heavy else data.knockback_resistance
	# Empujón (también al morir: sale despedido).
	planar_velocity = hb.get_knockback_direction(global_position) * hb.knockback * (1.0 - resistance)
	var current := state_machine.current.name
	if health.current <= 0.0 or current == &"Bones":
		return
	if hb.attack and hb.attack.knockup_height > 0.0 and current != &"Airborne":
		knockup_height = hb.attack.knockup_height
		state_machine.change_to(&"Airborne")
	elif current == &"Airborne":
		return
	elif heavy or data.light_hits_stagger or current == &"Windup":
		# Interrumpe lo que hiciera. El aviso se interrumpe siempre.
		state_machine.change_to(&"Hurt")


func _on_died() -> void:
	# Primera "muerte" con rearmarse activo: se queda como montón de huesos.
	if data.reassemble_enabled and not is_bones:
		state_machine.change_to(&"Bones")
		return
	state_machine.change_to(&"Dead")
	_drop_loot()
	died.emit(self)


func _drop_loot() -> void:
	if loot_drop_scene == null:
		return
	for entry in data.loot:
		if entry == null or entry.item == null or randf() > entry.chance:
			continue
		for i in randi_range(entry.amount.x, entry.amount.y):
			var drop := loot_drop_scene.instantiate() as Node3D
			drop.set(&"item", entry.item)
			get_parent().add_child(drop)
			drop.global_position = Vector3(global_position.x, 0.0, global_position.z)


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
