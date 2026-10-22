class_name InputTester
extends Control
## Pantalla de prueba del input map (B-004).
## Muestra qué acciones están pulsadas, el vector del stick izquierdo y los mandos conectados.
## La estructura vive en input_tester.tscn; este script solo actualiza textos y posiciones.

## Acciones que se listan, en este orden. Si añades una al Input Map, añádela aquí para verla.
@export var actions: PackedStringArray = [
	"move_left", "move_right", "move_up", "move_down",
	"attack_light", "attack_heavy", "jump", "dash",
	"skill_1", "skill_2", "pause",
]
## Píxeles que se desplaza el punto desde el centro con el stick al máximo.
@export var stick_radius: float = 20.0

@onready var _actions_label: Label = %ActionsLabel
@onready var _stick_area: Control = %StickArea
@onready var _stick_dot: Control = %StickDot
@onready var _stick_label: Label = %StickLabel
@onready var _device_label: Label = %DeviceLabel


func _process(_delta: float) -> void:
	_update_actions()
	_update_stick()
	_update_devices()


func _update_actions() -> void:
	var lines := PackedStringArray()
	for action in actions:
		var mark := "[X] " if Input.is_action_pressed(action) else "[ ] "
		lines.append(mark + action)
	_actions_label.text = "\n".join(lines)


func _update_stick() -> void:
	# get_vector ya aplica la deadzone de cada acción y normaliza la diagonal.
	var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var center := _stick_area.size / 2.0
	_stick_dot.position = center + v * stick_radius - _stick_dot.size / 2.0
	_stick_label.text = "stick (%.2f, %.2f)" % [v.x, v.y]


func _update_devices() -> void:
	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		_device_label.text = "sin mando"
		return
	var names := PackedStringArray()
	for id in pads:
		names.append(Input.get_joy_name(id))
	_device_label.text = "\n".join(names)
