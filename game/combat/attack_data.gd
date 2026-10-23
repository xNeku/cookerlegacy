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
## Desde cuándo se puede cortar el golpe con dash o salto (0 = siempre).
@export var cancel_from: float = 0.0

@export_group("Daño")
## Cada cuánto vuelve a golpear mientras la ventana de daño sigue abierta (s).
## 0 = un solo impacto por golpe.
@export var multi_hit_interval: float = 0.0
@export var damage: float = 10.0
## Fuerza del empujón al enemigo (px/s).
@export var knockback: float = 80.0
## Golpe fuerte (△, cargado...). Algunos enemigos solo se aturden o se mueven con
## golpes fuertes y reciben más daño de ellos (ver EnemyData).
@export var is_heavy: bool = false
## Si es mayor que 0, levanta al enemigo por los aires esta altura (px). Cargado, SaltoGolpe...
@export var knockup_height: float = 0.0

@export_group("Área")
## Área circular alrededor del atacante (giro...): empuja a cada uno hacia fuera.
## Con radial, el diámetro es hitbox_size.x y hitbox_distance se ignora.
@export var radial: bool = false
## Tamaño del área de golpe (largo hacia delante, ancho).
@export var hitbox_size: Vector2 = Vector2(22, 18)
## Distancia del centro del área al cuerpo.
@export var hitbox_distance: float = 14.0

@export_group("Paso adelante")
## Velocidad del pasito al pegar (0 = sin paso).
@export var lunge_speed: float = 120.0
## Cuánto dura el pasito antes de frenar.
@export var lunge_time: float = 0.08

@export_group("Sensación (game feel)")
## Congelado del juego al impactar (s). Da peso al golpe. 0 = sin hitstop.
@export var hitstop_time: float = 0.04
## Fuerza del temblor de cámara al impactar (px). 0 = sin temblor.
@export var shake_strength: float = 1.5
## Duración del temblor (s).
@export var shake_time: float = 0.1

@export_group("Movimiento durante el golpe")
## Tras el pasito, cuánto puedes moverte mientras pegas (1 = velocidad normal, 0 = clavado).
@export_range(0.0, 1.0) var move_speed_multiplier: float = 0.35
