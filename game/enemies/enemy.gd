class_name Enemy
extends CharacterBody2D
## Enemigo base. Datos en `data` (EnemyData); comportamiento en los estados de %StateMachine:
## Idle → Chase → Windup (aviso) → Attack → Recover, más Hurt, Airborne (levantado) y Dead.
## Cada tipo (rata, esqueleto...) es una escena heredada de enemy.tscn con su .tres y su sprite.

## Al morir (para loot, contadores, spawners...).
signal died(enemy: Enemy)

@export var data: EnemyData

@export_group("Aviso (placeholder)")
## Tinte durante el aviso, hasta que haya animación.
@export var windup_color: Color = Color(1.0, 0.35, 0.3)
## Temblor del sprite durante el aviso (px).
@export var windup_shake: float = 1.0

@export_group("Levantado (knockup)")
## Duración en el aire cuando lo levantan (s).
@export var knockup_duration: float = 0.7
## Tamaño mínimo de la sombra en lo alto.
@export_range(0.1, 1.0) var shadow_min_scale: float = 0.6

@export_group("Muerte")
## Tiempo que tarda en desaparecer al morir (s).
@export var death_time: float = 0.35

## A quién persigue (el cocinero, por el grupo "player").
var target: Node2D
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

var _next_attack_at: float = 0.0

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var shadow: Sprite2D = %Shadow
@onready var hitbox: Hitbox = %Hitbox
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var health: Health = %Health
@onready var state_machine: StateMachine = %StateMachine
@onready var _sprite_base_position: Vector2 = sprite.position


func _ready() -> void:
	health.max_health = data.max_health
	health.current = data.max_health
	hurtbox.heavy_damage_multiplier = data.heavy_damage_multiplier
	health.died.connect(_on_died)
	hurtbox.hit_received.connect(_on_hit_received)
	surround_angle = randf() * TAU
	target = get_tree().get_first_node_in_group(&"player") as Node2D


func distance_to_target() -> float:
	return global_position.distance_to(target.global_position) if target else INF


func direction_to_target() -> Vector2:
	return global_position.direction_to(target.global_position) if target else facing


## Se mueve hacia `point` a su velocidad (por `speed_multiplier`).
func move_towards(point: Vector2, delta: float, speed_multiplier: float = 1.0) -> void:
	var dir := global_position.direction_to(point)
	velocity = velocity.move_toward(dir * data.move_speed * speed_multiplier, data.acceleration * delta)
	face(dir)


func apply_friction(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, data.friction * delta)


func face(dir: Vector2) -> void:
	if absf(dir.x) > 0.01:
		facing = Vector2(signf(dir.x), 0.0)
		sprite.flip_h = facing.x < 0.0


## Reproduce `anim`; si no existe (falta arte), `fallback`.
func play_animation(anim: StringName, fallback: StringName = &"idle") -> void:
	var name := anim if sprite.sprite_frames.has_animation(anim) else fallback
	if sprite.animation != name:
		sprite.play(name)


func can_attack() -> bool:
	return _now() >= _next_attack_at


func start_attack_cooldown() -> void:
	_next_attack_at = _now() + data.attack_cooldown + randf() * data.attack_cooldown_random


## Sube el sprite `value` px y encoge la sombra (knockup).
func set_height(value: float) -> void:
	height = value
	sprite.position = _sprite_base_position + Vector2(0.0, -height)
	var ratio := clampf(value / maxf(knockup_height, 1.0), 0.0, 1.0)
	shadow.scale = Vector2.ONE * lerpf(1.0, shadow_min_scale, ratio)


## Desplaza el sprite sin mover el cuerpo (temblor del aviso).
func set_sprite_offset(offset: Vector2) -> void:
	sprite.position = _sprite_base_position + Vector2(0.0, -height) + offset


func _on_hit_received(hb: Hitbox) -> void:
	var heavy := hb.attack != null and hb.attack.is_heavy
	var resistance := data.heavy_knockback_resistance if heavy else data.knockback_resistance
	# Empujón (también al morir: sale despedido).
	velocity = hb.get_knockback_direction(global_position) * hb.knockback * (1.0 - resistance)
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
	died.emit(self)


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
