class_name TunnelExit
extends Node3D
## El túnel de salida al valle (detrás del bar). Al interactuar en la puerta rota,
## el cocinero entra solo andando de espaldas por los puntos de `Path` (Marker3D hijos,
## muévelos en el editor), la pantalla funde a negro y empieza la noche en `target_scene`.

@export var interactable: Interactable
## Escena a la que lleva (el valle).
@export_file("*.tscn") var target_scene: String = "res://game/levels/valley/valley.tscn"
## Nodo con los puntos (Marker3D) que recorre al entrar, en orden.
@export var path: Node3D
## Velocidad al entrar (1 = andando a tope).
@export_range(0.2, 1.0) var walk_speed: float = 0.6
## Cuándo empieza el fundido desde que echa a andar (s) y lo que dura.
@export var fade_delay: float = 0.7
@export var fade_time: float = 0.7

var _leaving: bool = false


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)


func _on_interacted(player: Player) -> void:
	if _leaving:
		return
	_leaving = true
	interactable.enabled = false
	var points: Array[Vector3] = []
	for child in path.get_children():
		if child is Marker3D:
			points.append(child.global_position)
	player.walk_path(points, walk_speed)
	await get_tree().create_timer(fade_delay).timeout
	await ScreenFade.fade_out(fade_time)
	get_tree().change_scene_to_file(target_scene)
