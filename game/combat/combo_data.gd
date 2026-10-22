class_name ComboData
extends Resource
## Una cadena de golpes (p. ej. el combo □). Cada golpe es un AttackData.

@export var attacks: Array[AttackData] = []
## Si acabas un golpe sin encadenar, tiempo que tienes para seguir el combo
## en vez de volver al primer golpe.
@export var reset_time: float = 0.35
