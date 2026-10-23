extends CanvasLayer
## HUD de prototipo: vida, cargas de dash y enfriamiento del giro.

## El cocinero (vida, dash y giro se leen de él).
@export var player: Player
## Color de una carga de dash disponible / gastada.
@export var dash_ready_color: Color = Color(0.55, 0.85, 1.0)
@export var dash_empty_color: Color = Color(0.2, 0.22, 0.3, 0.8)

@onready var _bar: ProgressBar = %HealthBar
@onready var _dash_pips: HBoxContainer = %DashPips
@onready var _spin_bar: ProgressBar = %SpinBar


func _ready() -> void:
	var health := player.health
	_bar.max_value = health.max_health
	_bar.value = health.current
	health.damaged.connect(_on_damaged)


func _process(_delta: float) -> void:
	var charges := player.get_dash_charges()
	var i := 0
	for pip in _dash_pips.get_children():
		(pip as ColorRect).color = dash_ready_color if i < charges else dash_empty_color
		i += 1
	_spin_bar.value = 1.0 - player.get_spin_cooldown_ratio()


func _on_damaged(_amount: float, current: float) -> void:
	_bar.value = current
