class_name WaveEntry
extends Resource
## Una línea de una oleada: cuántos enemigos de qué tipo.

@export var enemy_scene: PackedScene
@export_range(1, 30) var count: int = 3
