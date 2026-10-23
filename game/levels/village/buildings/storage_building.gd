extends Node3D
## El almacén de la villa. Interactuar abre/cierra el panel con todo lo que hay
## (grupo "storage_panel"); al alejarse se cierra. Su `LootTarget` (Marker3D en el grupo
## "storage_target") es adonde vuela el loot cuando cae en la villa.

@export var interactable: Interactable


func _ready() -> void:
	interactable.interacted.connect(func(_p: Player) -> void: get_tree().call_group(&"storage_panel", &"toggle"))
	interactable.player_exited.connect(func(_p: Player) -> void: get_tree().call_group(&"storage_panel", &"close"))
