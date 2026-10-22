class_name EnemyData
extends Resource
## Números de un tipo de enemigo. Cada enemigo (rata, esqueleto...) tiene su .tres.
## Su golpe es un AttackData, el mismo recurso que usan los golpes del cocinero.

@export_group("Vida")
@export var max_health: float = 30.0
## Cuánto ignora los empujones de golpes ligeros (0 = vuela, 1 = no se mueve).
@export_range(0.0, 1.0) var knockback_resistance: float = 0.0
## Lo mismo para golpes fuertes (△, cargado).
@export_range(0.0, 1.0) var heavy_knockback_resistance: float = 0.0
## Daño extra que le hacen los golpes fuertes (1 = normal).
@export var heavy_damage_multiplier: float = 1.0
## Si los golpes ligeros le aturden. Si no, solo le aturden los fuertes
## (y cualquier golpe durante el aviso, que siempre lo interrumpe).
@export var light_hits_stagger: bool = true
## Tiempo aturdido tras recibir un golpe (s).
@export var hurt_time: float = 0.22

@export_group("Movimiento")
@export var move_speed: float = 100.0
@export var acceleration: float = 900.0
@export var friction: float = 900.0

@export_group("Detección")
## A esta distancia del cocinero empieza a perseguir (px).
@export var detect_range: float = 200.0
## Si se aleja más que esto, deja de perseguir (px).
@export var lose_range: float = 400.0
## A esta distancia empieza el aviso y ataca (px).
@export var attack_range: float = 30.0

@export_group("Rodear")
## Distancia a la que intenta colocarse alrededor del cocinero (px).
@export var surround_radius: float = 0.0
## 0 = va recto hacia ti; 1 = busca su hueco alrededor (rodea).
@export_range(0.0, 1.0) var surround_weight: float = 0.0
## Lo que gira su hueco alrededor de ti (rad/s), para que no se queden quietas.
@export var surround_spin: float = 0.0

@export_group("Ataque")
## El golpe (daño, área, embestida, tiempos...).
@export var attack: AttackData
## Aviso antes de atacar (s). Es lo que deja esquivar.
@export var windup_time: float = 0.35
## Tiempo vendido tras atacar (s). La ventana para castigarle.
@export var recovery_time: float = 0.5
## Espera mínima entre ataques (s).
@export var attack_cooldown: float = 0.5
## Extra aleatorio a la espera (s), para que un grupo no ataque a la vez.
@export var attack_cooldown_random: float = 0.4

@export_group("Rearmarse (montón de huesos)")
## Al morir se queda como montón unos segundos; si no lo rematas, vuelve. (Q-17, por decidir.)
@export var reassemble_enabled: bool = false
## Segundos que dura el montón antes de recomponerse.
@export var reassemble_time: float = 3.0
## Vida con la que vuelve (proporción de la vida máxima).
@export_range(0.05, 1.0) var reassemble_health_ratio: float = 0.5
## Golpes que aguanta el montón antes de morir del todo (vida del montón).
@export var bones_health: float = 1.0
