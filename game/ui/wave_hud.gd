extends CanvasLayer
## Texto de oleada de la arena: "Oleada 3 · quedan 5".

## Spawner del que se leen las oleadas.
@export var spawner: WaveSpawner

var _wave: int = 0

@onready var _label: Label = %WaveLabel


func _ready() -> void:
	_label.text = ""
	spawner.wave_started.connect(func(n: int, _count: int) -> void: _wave = n)
	spawner.enemies_left_changed.connect(_on_left_changed)
	spawner.wave_cleared.connect(func(n: int) -> void: _label.text = "Oleada %d superada" % n)


func _on_left_changed(left: int) -> void:
	if left > 0:
		_label.text = "Oleada %d · quedan %d" % [_wave, left]
