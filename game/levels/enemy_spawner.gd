class_name EnemySpawner
extends Marker3D
## Crea un grupo de enemigos alrededor de su posición. Si `respawn` está activo,
## cuando el grupo muere entero vuelve a crear otro tras `respawn_delay`.
## Para pruebas sueltas; en niveles se usan oleadas (WaveSpawner).

## Escena del enemigo (rat.tscn, skeleton.tscn...).
@export var enemy_scene: PackedScene
## Dónde se añaden los enemigos (normalmente World).
@export var container: Node3D
@export_range(1, 20) var count: int = 5
## Radio en el que aparecen alrededor del spawner (m).
@export var spawn_radius: float = 1.25
@export var respawn: bool = true
@export var respawn_delay: float = 2.0

var _alive: int = 0


func _ready() -> void:
	# Diferido: el nivel tiene que estar entero antes de añadir enemigos.
	spawn.call_deferred()


func spawn() -> void:
	for i in count:
		var enemy := enemy_scene.instantiate() as Enemy
		var offset := Vector2.from_angle(randf() * TAU) * randf() * spawn_radius
		enemy.position = Vector3(global_position.x, 0.0, global_position.z) + Flat.to3(offset)
		container.add_child(enemy)
		enemy.died.connect(_on_enemy_died)
		_alive += 1


func _on_enemy_died(_enemy: Enemy) -> void:
	_alive -= 1
	if _alive <= 0 and respawn:
		await get_tree().create_timer(respawn_delay, false).timeout
		spawn()
