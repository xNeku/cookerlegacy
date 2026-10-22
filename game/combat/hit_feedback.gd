class_name HitFeedback
extends Node
## Cuando la Hitbox de su dueño impacta: hitstop, temblor de cámara y chispas.
## Cuánto de cada cosa lo dice el golpe (AttackData › Sensación).

## Hitbox cuyos impactos se escuchan.
@export var hitbox: Hitbox
## Escena de chispas a crear en el punto de impacto. Vacío = sin chispas.
@export var spark_scene: PackedScene
## Multiplicador global del temblor (para bajar o subir todo de golpe).
@export var shake_multiplier: float = 1.0
## Multiplicador global del hitstop.
@export var hitstop_multiplier: float = 1.0


func _ready() -> void:
	hitbox.hit_landed.connect(_on_hit_landed)


func _on_hit_landed(hurtbox: Area2D) -> void:
	var attack := hitbox.attack
	if attack == null:
		return
	HitStop.freeze(attack.hitstop_time * hitstop_multiplier)
	if attack.shake_strength > 0.0:
		# La cámara está en el grupo "game_camera": no hace falta conocerla.
		get_tree().call_group(&"game_camera", &"shake", attack.shake_strength * shake_multiplier, attack.shake_time)
	_spawn_spark(hurtbox)


func _spawn_spark(hurtbox: Area2D) -> void:
	if spark_scene == null:
		return
	var spark := spark_scene.instantiate() as Node2D
	# Punto de impacto: centro de la forma de la Hurtbox, desplazado hacia el atacante.
	var target_pos := hurtbox.global_position
	for child in hurtbox.get_children():
		if child is CollisionShape2D:
			target_pos = child.global_position
			break
	var parent := get_tree().current_scene if get_tree().current_scene else hurtbox.owner.get_parent()
	parent.add_child(spark)
	var dir := hitbox.get_knockback_direction(target_pos)
	spark.global_position = target_pos - dir * 4.0
	spark.rotation = dir.angle()
