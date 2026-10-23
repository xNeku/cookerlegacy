class_name TrainingDummy
extends StaticBody3D
## Muñeco de entrenamiento: recibe golpes y enseña el combo y el daño acumulado.
## El flash/aplastón los pone su SpriteFX y los números su DamageNumbers. No muere.

## Segundos sin recibir golpes para resetear el contador de combo.
@export var combo_reset_time: float = 1.2

var _hits_in_row: int = 0
var _damage_in_row: float = 0.0

@onready var _hurtbox: Hurtbox = %Hurtbox
@onready var _label: Label3D = %InfoLabel
@onready var _reset_timer: Timer = %ResetTimer


func _ready() -> void:
	_hurtbox.hit_received.connect(_on_hit_received)
	_reset_timer.timeout.connect(_on_reset_timeout)
	_label.text = ""


func _on_hit_received(_hitbox: Hitbox) -> void:
	_hits_in_row += 1
	_damage_in_row += _hurtbox.last_damage
	_label.text = "x%d  ·  %d" % [_hits_in_row, roundi(_damage_in_row)]
	_reset_timer.start(combo_reset_time)


func _on_reset_timeout() -> void:
	_hits_in_row = 0
	_damage_in_row = 0.0
	_label.text = ""
