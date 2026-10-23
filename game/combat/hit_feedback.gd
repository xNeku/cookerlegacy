class_name HitFeedback
extends Node
## Cuando la Hitbox de su dueño impacta: hitstop, temblor y "punch" de cámara, y efecto
## de impacto (chispas + destello). Cuánto de cada cosa lo dice el golpe (AttackData › Sensación).

## Hitbox cuyos impactos se escuchan.
@export var hitbox: Hitbox
## Efecto de impacto a crear en el punto del golpe. Vacío = sin efecto.
@export var impact_scene: PackedScene
## Efecto de impacto para golpes fuertes (más grande). Vacío = usa el normal.
@export var heavy_impact_scene: PackedScene
## Multiplicador global del temblor (para bajar o subir todo de golpe).
@export var shake_multiplier: float = 1.0
## Multiplicador global del hitstop.
@export var hitstop_multiplier: float = 1.0


func _ready() -> void:
	hitbox.hit_landed.connect(_on_hit_landed)


func _on_hit_landed(hurtbox: Area3D) -> void:
	var attack := hitbox.attack
	if attack == null:
		return
	HitStop.freeze(attack.hitstop_time * hitstop_multiplier)
	if attack.shake_strength > 0.0:
		# La cámara está en el grupo "game_camera": no hace falta conocerla.
		get_tree().call_group(&"game_camera", &"shake", attack.shake_strength * shake_multiplier, attack.shake_time)
	if attack.camera_punch > 0.0:
		get_tree().call_group(&"game_camera", &"punch", attack.camera_punch)
	_spawn_impact(hurtbox as Hurtbox, attack)


func _spawn_impact(hurtbox: Hurtbox, attack: AttackData) -> void:
	var scene := heavy_impact_scene if (attack.is_heavy and heavy_impact_scene) else impact_scene
	if scene == null or hurtbox == null:
		return
	var point := hurtbox.get_center()
	var dir := hitbox.get_knockback_direction(point)
	# Un poco hacia el atacante y hacia la cámara, para que no quede tapado por el sprite.
	var pos := point - Flat.to3(dir) * 0.15 + Vector3(0.0, 0.0, 0.2)
	FxSpawner.spawn(self, scene, pos, Flat.yaw(dir), attack.vfx_color)
