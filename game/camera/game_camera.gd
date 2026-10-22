class_name GameCamera
extends Camera2D
## Cámara que sigue a un objetivo. El suavizado y los límites son propiedades de Camera2D
## (Inspector › Position Smoothing / Limit). Aquí vivirá el screenshake (B-011).

## Nodo al que sigue (normalmente el Player).
@export var target: Node2D


func _ready() -> void:
	if target:
		global_position = target.global_position
		reset_smoothing()


func _physics_process(_delta: float) -> void:
	if target:
		global_position = target.global_position
