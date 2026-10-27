class_name Interactable
extends Area3D
## Algo con lo que el cocinero puede interactuar (puerta, almacén, forja, muelle...).
## Cuando está cerca, sale el aviso encima ("X Salir al valle") y al pulsar interactuar
## (X / E) avisa con `interacted`. Quien lo use (la puerta, el almacén...) se engancha a esa señal.
## El área se ajusta con su CollisionShape3D hijo.

signal interacted(player: Player)
## El cocinero entra o sale del área.
signal player_entered(player: Player)
signal player_exited(player: Player)

## Texto del aviso.
@export var prompt_text: String = "Interactuar"
## Si está apagado no sale aviso ni se puede usar.
@export var enabled: bool = true
## Radio del área (m). 0 = el de la forma tal cual está en la escena.
@export var radius: float = 0.0

@onready var _prompt: Label3D = %Prompt

var _player: Player


func _ready() -> void:
	if radius > 0.0:
		var shape := %Shape as CollisionShape3D
		var cyl := (shape.shape as CylinderShape3D).duplicate() as CylinderShape3D
		cyl.radius = radius
		shape.shape = cyl
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_prompt.visible = false


func _process(_delta: float) -> void:
	var shown := enabled and _player != null and _player.get_interactable() == self
	_prompt.visible = shown
	if shown:
		var key := "X" if InputMode.is_gamepad() else "E"
		_prompt.text = "%s  %s" % [key, prompt_text]


func interact(player: Player) -> void:
	if enabled:
		interacted.emit(player)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_player = body
		_player.add_interactable(self)
		player_entered.emit(_player)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		(body as Player).remove_interactable(self)
		player_exited.emit(body)
		_player = null
