class_name DamageNumbers
extends Node
## Saca un número de daño cada vez que su Hurtbox recibe un golpe.

@export var hurtbox: Hurtbox
@export var number_scene: PackedScene
@export var normal_color: Color = Color(1.0, 0.97, 0.9)
## Color de los golpes fuertes (más grandes).
@export var heavy_color: Color = Color(1.0, 0.62, 0.25)
## Altura sobre el centro del cuerpo donde aparece (m).
@export var height: float = 0.45


func _ready() -> void:
	hurtbox.hit_received.connect(_on_hit_received)


func _on_hit_received(hitbox: Hitbox) -> void:
	if number_scene == null:
		return
	var heavy := hitbox.attack != null and hitbox.attack.is_heavy
	var label := number_scene.instantiate() as DamageNumber
	label.setup(heavy_color if heavy else normal_color, hurtbox.last_damage, heavy)
	var parent: Node = get_tree().current_scene if get_tree().current_scene else get_tree().root
	label.position = hurtbox.get_center() + Vector3(0.0, height, 0.15)
	parent.add_child(label)
