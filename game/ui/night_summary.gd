class_name NightSummary
extends CanvasLayer
## Pantalla de fin de noche: fundido a negro y resumen (cómo acabó, distancia, bichos y loot).
## Funciona con el juego en pausa. Se cierra con □ / clic / Enter.

signal continue_pressed

## Título según cómo acabó la noche.
@export var dawn_title: String = "Amanece"
@export var died_title: String = "Te han tumbado"
## Duración del fundido (s).
@export var fade_time: float = 0.6
## Espera antes de aceptar input (para no saltarlo sin querer machacando botones).
@export var input_delay: float = 0.8
## Fila de loot (icono + cantidad).
@export var loot_row_scene: PackedScene

@onready var _fade: ColorRect = %Fade
@onready var _panel: Control = %Panel
@onready var _title: Label = %Title
@onready var _distance: Label = %Distance
@onready var _kills: Label = %Kills
@onready var _loot: Container = %LootList
@onready var _empty: Label = %EmptyLoot
@onready var _hint: Label = %Hint

var _accepting: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func show_summary(reason: StringName, distance: float, kills: int, loot: Array[Dictionary]) -> void:
	visible = true
	_title.text = dawn_title if reason == &"dawn" else died_title
	_distance.text = "%d m" % roundi(distance)
	_kills.text = str(kills)
	for child in _loot.get_children():
		child.queue_free()
	for entry in loot:
		var row := loot_row_scene.instantiate()
		_loot.add_child(row)
		row.setup(entry.item, entry.amount)
	_empty.visible = loot.is_empty()
	_fade.modulate.a = 0.0
	_panel.modulate.a = 0.0
	_hint.visible = false
	# Tiempo real: que no dependa de cámaras lentas ni hitstops.
	var tween := create_tween().set_ignore_time_scale(true)
	tween.tween_property(_fade, "modulate:a", 1.0, fade_time)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(input_delay)
	tween.tween_callback(func() -> void:
		_hint.visible = true
		_accepting = true)


func _input(event: InputEvent) -> void:
	if not _accepting:
		return
	if event.is_action_pressed(&"attack_light") or event.is_action_pressed(&"ui_accept"):
		_accepting = false
		get_viewport().set_input_as_handled()
		continue_pressed.emit()
