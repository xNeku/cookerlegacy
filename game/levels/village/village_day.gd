class_name VillageDay
extends Node
## Lleva el día en la villa: coloca al cocinero en `spawn`, quita el fundido y enseña
## el cartel del día. (El ciclo de mañana → tarde → servicio del bar irá aquí en Fase 3.)

@export var player: Player
## Dónde aparece el cocinero al empezar el día (delante del bar).
@export var spawn: Marker3D
@export var banner: DayBanner
## Lo que tarda en quitarse el negro al llegar (s).
@export var fade_in_time: float = 0.8


func _ready() -> void:
	if spawn:
		player.global_position = Vector3(spawn.global_position.x, 0.0, spawn.global_position.z)
		player.facing = Vector2.DOWN
	if ScreenFade.is_black():
		ScreenFade.fade_in(fade_in_time)
	if banner:
		banner.show_day(GameState.day)
