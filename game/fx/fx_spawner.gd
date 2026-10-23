class_name FxSpawner
## Crea efectos (escenas .tscn de game/fx/) en el mundo. Cada efecto se reproduce solo y se borra.


## Crea `scene` en `position` del mundo, girado `yaw` (rad) en Y. Si el efecto tiene
## `setup(color, attack)`, se le llama antes de añadirlo (para teñirlo o adaptarlo al golpe).
static func spawn(ctx: Node, scene: PackedScene, position: Vector3, yaw: float = 0.0,
		color: Color = Color.WHITE, attack: AttackData = null) -> Node3D:
	if scene == null:
		return null
	var fx := scene.instantiate() as Node3D
	if fx.has_method(&"setup"):
		fx.call(&"setup", color, attack)
	var parent: Node = ctx.get_tree().current_scene
	if parent == null:
		parent = ctx.get_tree().root
	# Posición y giro antes de añadirlo, para que el efecto ya los tenga en su _ready.
	# (La escena principal no se mueve: su espacio es el del mundo.)
	fx.position = position
	fx.rotation.y = yaw
	parent.add_child(fx)
	return fx


## Igual, pero el efecto va pegado a `parent` (le sigue al moverse). `offset` en local.
static func attach(parent: Node3D, scene: PackedScene, offset: Vector3, yaw: float = 0.0,
		color: Color = Color.WHITE, attack: AttackData = null) -> Node3D:
	if scene == null:
		return null
	var fx := scene.instantiate() as Node3D
	if fx.has_method(&"setup"):
		fx.call(&"setup", color, attack)
	fx.position = offset
	fx.rotation.y = yaw
	parent.add_child(fx)
	return fx
