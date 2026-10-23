class_name NightRun
extends Node
## Lleva una noche de principio a fin: coloca al cocinero al inicio del camino, cuenta lo que
## avanzas y lo que matas, y acaba la noche al amanecer o si te tumban (cámara lenta,
## fundido y resumen). Desde el resumen se vuelve a `return_scene` (la villa, cuando exista).

signal ended(reason: StringName)

@export var player: Player
@export var path: ValleyPath
@export var night: NightCycle
@export var director: HordeDirector
@export var summary: NightSummary
## Escena a la que se vuelve al acabar. Vacía = se repite la noche.
@export_file("*.tscn") var return_scene: String = ""
## Dónde empieza el cocinero (m desde el inicio del camino).
@export var start_offset: float = 2.5

@export_group("Final")
## Velocidad del juego durante la cámara lenta del final.
@export_range(0.05, 1.0) var end_slowmo: float = 0.3
## Duración de la cámara lenta (s reales) antes del resumen.
@export var end_slowmo_time: float = 1.2

## Metros más lejos a los que has llegado esta noche.
var best_distance: float = 0.0
var is_over: bool = false


func _ready() -> void:
	Storage.begin_night()
	var p := path.point_at(start_offset)
	player.global_position = p
	player.update_facing(Flat.of(path.forward_at(start_offset)))
	player.died.connect(end_night.bind(&"died"))
	night.dawn.connect(end_night.bind(&"dawn"))
	summary.continue_pressed.connect(_on_continue)


func _physics_process(_delta: float) -> void:
	if is_over:
		return
	best_distance = maxf(best_distance, path.offset_of(player.global_position) - start_offset)


func get_kills() -> int:
	return director.kills if director else 0


## Acaba la noche. `reason`: &"dawn" (amanece) o &"died" (te tumban).
func end_night(reason: StringName) -> void:
	if is_over:
		return
	is_over = true
	night.running = false
	director.enabled = false
	ended.emit(reason)
	HitStop.base_time_scale = end_slowmo
	await get_tree().create_timer(end_slowmo_time * end_slowmo, true, false, false).timeout
	HitStop.base_time_scale = 1.0
	get_tree().paused = true
	summary.show_summary(reason, best_distance, get_kills(), Storage.night_loot())


func _on_continue() -> void:
	get_tree().paused = false
	HitStop.base_time_scale = 1.0
	Engine.time_scale = 1.0
	if return_scene.is_empty():
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file(return_scene)
