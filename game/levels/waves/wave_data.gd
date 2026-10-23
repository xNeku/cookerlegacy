class_name WaveData
extends Resource
## Una oleada: varias líneas (p. ej. 4 ratas + 1 esqueleto).

@export var entries: Array[WaveEntry] = []
## Espera antes de que aparezca esta oleada (s).
@export var delay: float = 1.5


func total_count() -> int:
	var total := 0
	for entry in entries:
		total += entry.count
	return total
