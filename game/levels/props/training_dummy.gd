class_name TrainingDummy
extends StaticBody2D
## Muñeco de entrenamiento: recibe golpes y enseña el daño y el combo.
## El destello y el aplastón los pone su HitFlash. No muere (Health inmortal).

## Segundos sin recibir golpes para resetear el contador de combo.
@export var combo_reset_time: float = 1.2

var _hits_in_row: int = 0
var _damage_in_row: float = 0.0

@onready var _hurtbox: Hurtbox = %Hurtbox
@onready var _label: Label = %InfoLabel
@onready var _reset_timer: Timer = %ResetTimer


func _ready() -> void:
	_hurtbox.hit_received.connect(_on_hit_received)
	_reset_timer.timeout.connect(_on_reset_timeout)
	_label.text = ""


func _on_hit_received(hitbox: Hitbox) -> void:
	_hits_in_row += 1
	_damage_in_row += hitbox.damage
	_label.text = "-%d  x%d\n(%d)" % [hitbox.damage, _hits_in_row, _damage_in_row]
	_reset_timer.start(combo_reset_time)


func _on_reset_timeout() -> void:
	_hits_in_row = 0
	_damage_in_row = 0.0
	_label.text = ""
