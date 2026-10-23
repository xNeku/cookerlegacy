class_name LootEntry
extends Resource
## Una línea de loot de un enemigo: qué suelta, con qué probabilidad y cuánto.

@export var item: ItemData
## Probabilidad de soltarlo (1 = siempre).
@export_range(0.0, 1.0) var chance: float = 1.0
## Cuántos suelta (mínimo y máximo).
@export var amount: Vector2i = Vector2i(1, 1)
