class_name HordeEntry
extends Resource
## Un tipo de grupo que puede soltar el HordeDirector: qué bicho, cuántos juntos,
## lo frecuente que es y desde qué distancia del valle empieza a salir.

## El enemigo (rat.tscn, skeleton.tscn...).
@export var enemy_scene: PackedScene
## Lo frecuente que sale respecto a los demás (2 = el doble que uno con 1).
@export var weight: float = 1.0
## Cuántos salen juntos (mínimo y máximo).
@export var group_size: Vector2i = Vector2i(1, 1)
## Metros recorridos a partir de los que empieza a salir.
@export var from_distance: float = 0.0
## Metros a partir de los que deja de salir (negativo = nunca deja de salir).
@export var to_distance: float = -1.0


func is_available(distance: float) -> bool:
	return distance >= from_distance and (to_distance < 0.0 or distance <= to_distance)
