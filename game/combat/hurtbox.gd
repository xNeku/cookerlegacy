class_name Hurtbox
extends Area3D
## Área que recibe golpes. Al entrar una Hitbox activa, aplica daño a `health`
## y avisa con `hit_received` (para empujón, flash, números de daño...).
## La forma se añade como hijo CollisionShape3D en la escena de cada dueño.

signal hit_received(hitbox: Hitbox)

## Vida a la que se resta el daño. Puede quedar vacía si solo interesa la señal.
@export var health: Health

## Multiplicador de daño de los golpes fuertes (`AttackData.is_heavy`). Lo pone el dueño.
var heavy_damage_multiplier: float = 1.0
## Si está activo, ignora los golpes (dash, invulnerabilidad tras recibir daño...).
## Lo gestiona el dueño.
var invulnerable: bool = false
## Daño real del último golpe recibido (con multiplicadores). Para números de daño.
var last_damage: float = 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


## Centro de la forma (punto de impacto para efectos).
func get_center() -> Vector3:
	for child in get_children():
		if child is CollisionShape3D:
			return child.global_position
	return global_position


func _on_area_entered(area: Area3D) -> void:
	var hitbox := area as Hitbox
	if hitbox == null or invulnerable:
		return
	var heavy := hitbox.attack != null and hitbox.attack.is_heavy
	last_damage = hitbox.damage * (heavy_damage_multiplier if heavy else 1.0)
	if health:
		health.take_damage(last_damage)
	hit_received.emit(hitbox)
	hitbox.hit_landed.emit(self)
