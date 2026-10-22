extends CanvasLayer
## HUD mínimo de prototipo: barra de vida del cocinero.

## Vida a mostrar (la del Player).
@export var health: Health

@onready var _bar: ProgressBar = %HealthBar


func _ready() -> void:
	_bar.max_value = health.max_health
	_bar.value = health.current
	health.damaged.connect(_on_damaged)


func _on_damaged(_amount: float, current: float) -> void:
	_bar.value = current
