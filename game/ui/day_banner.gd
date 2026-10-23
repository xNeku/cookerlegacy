class_name DayBanner
extends CanvasLayer
## Cartel al empezar el día ("Día 3") que aparece y se va, y el día en una esquina.

## Texto debajo del número de día.
@export var subtitle: String = "Amanece en la villa"
## Espera antes de salir, tiempo a la vista y fundidos (s).
@export var delay: float = 0.5
@export var hold_time: float = 1.6
@export var fade_time: float = 0.4

@onready var _banner: Control = %Banner
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _corner: Label = %DayCorner


func _ready() -> void:
	_banner.modulate.a = 0.0


func show_day(day: int) -> void:
	_title.text = "Día %d" % day
	_subtitle.text = subtitle
	_corner.text = "Día %d" % day
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(_banner, "modulate:a", 1.0, fade_time)
	tween.tween_interval(hold_time)
	tween.tween_property(_banner, "modulate:a", 0.0, fade_time)
