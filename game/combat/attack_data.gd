class_name AttackData
extends Resource
## Un golpe (del cocinero o de un enemigo). Tiempos en segundos desde que empieza el golpe.
## Distancias en metros (32 px de arte = 1 m).

## Animación a reproducir (se le añade _down/_up/_side en el cocinero).
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
## Fuerza del empujón (m/s).
@export var knockback: float = 2.5
## Golpe fuerte (△, cargado...). Algunos enemigos solo se aturden o se mueven con
## golpes fuertes y reciben más daño de ellos (ver EnemyData).
@export var is_heavy: bool = false
## Si es mayor que 0, levanta al enemigo por los aires esta altura (m). Cargado, SaltoGolpe...
@export var knockup_height: float = 0.0

@export_group("Área")
## Área circular alrededor del atacante (giro...): empuja a cada uno hacia fuera.
## Con radial, el diámetro es hitbox_size.x y hitbox_distance se ignora.
@export var radial: bool = false
## Tamaño del área en el suelo (m): x = largo hacia delante, y = ancho.
@export var hitbox_size: Vector2 = Vector2(0.7, 0.55)
## Alto del área (m). Generoso para que los golpes en el aire alcancen a los bajitos.
@export var hitbox_height: float = 1.6
## Distancia del centro del área al cuerpo (m).
@export var hitbox_distance: float = 0.45

@export_group("Paso adelante")
## Velocidad del pasito al pegar (m/s; 0 = sin paso).
@export var lunge_speed: float = 3.75
## Cuánto dura el pasito antes de frenar.
@export var lunge_time: float = 0.08

@export_group("Sensación (game feel)")
## Congelado del juego al impactar (s). Da peso al golpe. 0 = sin hitstop.
@export var hitstop_time: float = 0.04
## Fuerza del temblor de cámara al impactar (m). 0 = sin temblor.
@export var shake_strength: float = 0.05
## Duración del temblor (s).
@export var shake_time: float = 0.1
## "Golpe" de zoom de la cámara al impactar (grados de FOV). 0 = nada.
@export var camera_punch: float = 0.0

@export_group("Efecto visual (tajo)")
## Escena del efecto al empezar el golpe (slash_fx.tscn...). Vacío = sin efecto.
@export var vfx_scene: PackedScene
## Color del tajo.
@export var vfx_color: Color = Color(1.0, 0.85, 0.55)
## Apertura del arco (grados). 360 = círculo completo (giro).
@export_range(10.0, 360.0) var vfx_arc_degrees: float = 150.0
## Radio exterior del tajo (m).
@export var vfx_radius: float = 0.9
## Sentido del barrido: de izquierda a derecha o al revés (alterna en los combos).
@export var vfx_flip: bool = false
## Vueltas que da el efecto durante el golpe (giro). 0 = no gira.
@export var vfx_turns: float = 0.0
## Onda expansiva en el suelo cuando empieza a hacer daño (cargado, giro...).
@export var vfx_ring: bool = false

@export_group("Movimiento durante el golpe")
## Tras el pasito, cuánto puedes moverte mientras pegas (1 = velocidad normal, 0 = clavado).
@export_range(0.0, 1.0) var move_speed_multiplier: float = 0.35
