class_name Hitbox
extends Area3D
## Área que hace daño. La activa quien ataca durante la ventana de golpe.
## Quien recibe es la Hurtbox (ella detecta a la Hitbox).
## La forma se elige por golpe: caja delante (largo × ancho × alto) o cilindro alrededor (radial).

## Emitida cuando este golpe impacta en una Hurtbox (para hitstop, chispas, sonido...).
signal hit_landed(hurtbox: Area3D)

## Muestra el área mientras está activa (para ajustar golpes).
@export var show_debug_shape: bool = false
## Color del área mostrada.
@export var debug_color: Color = Color(1, 0.85, 0.4, 0.35)

## Golpe actual (daño, empuje, hitstop, temblor...). Lo lee quien recibe y el feedback.
var attack: AttackData
## Dirección del golpe en el suelo (para el empujón y las chispas).
var direction: Vector2 = Vector2.RIGHT
var damage: float:
	get:
		return attack.damage if attack else 0.0
var knockback: float:
	get:
		return attack.knockback if attack else 0.0

var _active_flag: bool = false
var _box_shape: BoxShape3D
var _cylinder_shape: CylinderShape3D
var _debug_material: StandardMaterial3D

@onready var _shape: CollisionShape3D = %Shape
@onready var _debug_mesh: MeshInstance3D = %DebugMesh


func _ready() -> void:
	# Cada instancia tiene sus propias formas, porque cambian de tamaño por golpe.
	_box_shape = BoxShape3D.new()
	_cylinder_shape = CylinderShape3D.new()
	_shape.shape = _box_shape
	_debug_material = StandardMaterial3D.new()
	_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_debug_material.albedo_color = debug_color
	_debug_mesh.visible = false
	set_active(false)


## Prepara el área para el golpe `new_attack` en dirección `dir` (en el suelo).
func configure(new_attack: AttackData, dir: Vector2) -> void:
	attack = new_attack
	direction = dir
	rotation.y = Flat.yaw(dir)
	var height := new_attack.hitbox_height
	if new_attack.radial:
		_cylinder_shape.radius = new_attack.hitbox_size.x / 2.0
		_cylinder_shape.height = height
		_shape.shape = _cylinder_shape
		_shape.position = Vector3.ZERO
		var cyl := CylinderMesh.new()
		cyl.top_radius = _cylinder_shape.radius
		cyl.bottom_radius = _cylinder_shape.radius
		cyl.height = height
		_debug_mesh.mesh = cyl
	else:
		# hitbox_size.x = largo hacia delante, .y = ancho.
		_box_shape.size = Vector3(new_attack.hitbox_size.x, height, new_attack.hitbox_size.y)
		_shape.shape = _box_shape
		_shape.position = Vector3(new_attack.hitbox_distance, 0.0, 0.0)
		var box := BoxMesh.new()
		box.size = _box_shape.size
		_debug_mesh.mesh = box
	_debug_mesh.position = _shape.position
	_debug_mesh.material_override = _debug_material


func set_active(active: bool) -> void:
	if active == _active_flag:
		return
	_active_flag = active
	_shape.set_deferred("disabled", not active)
	_debug_mesh.visible = active and show_debug_shape


func is_active() -> bool:
	return _active_flag


## Dirección del empujón (en el suelo) para quien está en `target_position`:
## la del golpe, o hacia fuera desde el centro si el golpe es radial.
func get_knockback_direction(target_position: Vector3) -> Vector2:
	if attack and attack.radial:
		var away := Flat.of(target_position - global_position)
		return away.normalized() if not away.is_zero_approx() else direction
	return direction
