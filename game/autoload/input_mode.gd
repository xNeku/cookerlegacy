extends Node
## Autoload "InputMode": sabe si el jugador está usando mando o teclado+ratón,
## mirando el último input que llega. Cambia solo, en caliente.

signal mode_changed(mode: Mode)

enum Mode { KEYBOARD_MOUSE, GAMEPAD }

## Cuánto hay que mover un stick para que cuente como "usar el mando" (evita drift).
@export_range(0.0, 1.0) var stick_threshold: float = 0.4
## Píxeles que hay que mover el ratón para que cuente como "usar el ratón".
@export var mouse_threshold: float = 3.0

var mode: Mode = Mode.KEYBOARD_MOUSE


func is_gamepad() -> bool:
	return mode == Mode.GAMEPAD


func _input(event: InputEvent) -> void:
	var detected := mode
	if event is InputEventJoypadButton:
		detected = Mode.GAMEPAD
	elif event is InputEventJoypadMotion and absf(event.axis_value) > stick_threshold:
		detected = Mode.GAMEPAD
	elif event is InputEventKey or event is InputEventMouseButton:
		detected = Mode.KEYBOARD_MOUSE
	elif event is InputEventMouseMotion and event.relative.length() > mouse_threshold:
		detected = Mode.KEYBOARD_MOUSE
	if detected != mode:
		mode = detected
		mode_changed.emit(mode)
