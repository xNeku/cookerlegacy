extends Node
## Arranque del juego: carga la escena de `start_scene`.
## Para probar otra cosa al darle a Play (la sala de pruebas, la villa...), cámbiala aquí.

@export var start_scene: PackedScene


func _ready() -> void:
	if start_scene:
		get_tree().change_scene_to_packed.call_deferred(start_scene)
