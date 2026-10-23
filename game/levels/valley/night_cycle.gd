@tool
class_name NightCycle
extends Node
## El reloj de la noche. Avanza de noche cerrada (0) a amanecer (1) en `duration` segundos
## y va cambiando el cielo, la luz ambiente, la niebla, la luna y el sol.
## Al llegar a 1 avisa con `dawn` (se acaba la noche).
##
## Para ajustar los colores sin jugar: mueve `preview` en el Inspector y mira la escena.
## En los degradados, la izquierda es el principio de la noche y la derecha el amanecer.

signal dawn

## Lo que dura la noche (s reales a velocidad normal).
@export var duration: float = 240.0
## Empieza a correr sola al cargar.
@export var autostart: bool = true

@export_group("Nodos")
@export var environment: WorldEnvironment
@export var moon: DirectionalLight3D
@export var sun: DirectionalLight3D

@export_group("Colores")
## Color del fondo/cielo.
@export var sky_colors: Gradient
## Color de la luz ambiente.
@export var ambient_colors: Gradient
## Color de la niebla.
@export var fog_colors: Gradient
## Color del sol (rojizo al salir).
@export var sun_colors: Gradient

@export_group("Intensidades")
@export var moon_energy: Curve
@export var sun_energy: Curve
@export var ambient_energy: Curve

@export_group("Sol")
## Inclinación del sol al principio y al final (grados; más negativo = más alto).
@export var sun_pitch: Vector2 = Vector2(-4.0, -24.0)

@export_group("Probar en el editor")
## Mueve esto para ver cómo queda cada momento de la noche (solo en el editor).
@export_range(0.0, 1.0) var preview: float = 0.0:
	set(value):
		preview = value
		if Engine.is_editor_hint() and is_inside_tree():
			apply(preview)

var running: bool = false
var elapsed: float = 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		apply(preview)
		return
	apply(0.0)
	running = autostart


## 0 = acaba de empezar, 1 = amanece.
func get_progress() -> float:
	return clampf(elapsed / maxf(duration, 0.01), 0.0, 1.0)


## Segundos que quedan de noche.
func get_time_left() -> float:
	return maxf(duration - elapsed, 0.0)


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not running:
		return
	elapsed += delta
	apply(get_progress())
	if elapsed >= duration:
		running = false
		dawn.emit()


## Pone el cielo y las luces como en el momento `t` (0..1) de la noche.
func apply(t: float) -> void:
	if environment and environment.environment:
		var env := environment.environment
		if sky_colors:
			env.background_color = sky_colors.sample(t)
		if ambient_colors:
			env.ambient_light_color = ambient_colors.sample(t)
		if ambient_energy:
			env.ambient_light_energy = ambient_energy.sample(t)
		if fog_colors:
			env.fog_light_color = fog_colors.sample(t)
	if moon and moon_energy:
		moon.light_energy = moon_energy.sample(t)
		moon.visible = moon.light_energy > 0.01
	if sun:
		if sun_energy:
			sun.light_energy = sun_energy.sample(t)
		if sun_colors:
			sun.light_color = sun_colors.sample(t)
		sun.visible = sun.light_energy > 0.01
		sun.rotation_degrees.x = lerpf(sun_pitch.x, sun_pitch.y, t)
