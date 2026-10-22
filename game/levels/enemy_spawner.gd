class_name EnemySpawner
extends Marker2D
## Crea un grupo de enemigos alrededor de su posición. Si `respawn` está activo,
## cuando el grupo muere entero vuelve a crear otro tras `respawn_delay`.
## Los enemigos se añaden a `container` (el nodo World con Y-sort del nivel).

## Escena del enemigo (rat.tscn, skeleton.tscn...).
@export var enemy_scene: PackedScene
## Dónde se añaden los enemigos (normalmente World, para el Y-sort).
@export var container: Node2D
@export_range(1, 20) var count: int = 5
## Radio en el que aparecen alrededor del spawner (px).
@export var spawn_radius: float = 40.0
@export var respawn: bool = true
@export var respawn_delay: float = 2.0

var _alive: int = 0


func _ready() -> void:
	# Diferido: el nivel tiene que estar entero antes de añadir enemigos.
	spawn.call_deferred()


func spawn() -> void:
	for i in count:
		var enemy := enemy_scene.instantiate() as Enemy
		container.add_child(enemy)
		var offset := Vector2.from_angle(randf() * TAU) * randf() * spawn_radius
		enemy.global_position = global_position + offset
		enemy.died.connect(_on_enemy_died)
		_alive += 1


func _on_enemy_died(_enemy: Enemy) -> void:
	_alive -= 1
	if _alive <= 0 and respawn:
		await get_tree().create_timer(respawn_delay).timeout
		spawn()
