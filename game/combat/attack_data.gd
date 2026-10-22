class_name AttackData
extends Resource
## Un golpe. Todos los tiempos en segundos desde que empieza el golpe.

## Animación a reproducir (se le añade _down/_up/_side). Si no existe, usa idle.
@export var animation: StringName = &"attack_1"

@export_group("Tiempos")
## Duración total del golpe.
@export var duration: float = 0.32
## Cuándo empieza a hacer daño.
@export var hit_start: float = 0.06
## Cuándo deja de hacer daño.
@export var hit_end: float = 0.14
## Desde cuándo sale el siguiente golpe si ya pulsaste (se puede pulsar antes: se guarda).
@export var chain_from: float = 0.18

@export_group("Daño")
@export var damage: float = 10.0
## Fuerza del empujón al enemigo (px/s).
@export var knockback: float = 80.0

@export_group("Área")
## Tamaño del área de golpe (largo hacia delante, ancho).
@export var hitbox_size: Vector2 = Vector2(22, 18)
## Distancia del centro del área al cuerpo.
@export var hitbox_distance: float = 14.0

@export_group("Paso adelante")
## Velocidad del pasito al pegar (0 = sin paso).
@export var lunge_speed: float = 120.0
## Cuánto dura el pasito antes de frenar.
@export var lunge_time: float = 0.08
