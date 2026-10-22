class_name PlayerState
extends State
## Base de los estados del cocinero. Da acceso tipado al Player
## y la comprobación común de acciones (atacar, cargar, dash, saltar).

## El Player dueño de este estado (la raíz de player.tscn).
var player: Player:
	get:
		return owner as Player


## Si se ha pulsado una acción, cambia al estado que toca y devuelve true.
## Lo usan los estados "libres" (Idle, Move) para no repetir el mismo bloque.
func try_start_action() -> bool:
	if Input.is_action_just_pressed("dash") and player.can_dash():
		machine.change_to(&"Dash")
		return true
	if Input.is_action_just_pressed("jump"):
		machine.change_to(&"Jump")
		return true
	if Input.is_action_just_pressed("attack_light"):
		machine.change_to(&"LightAttack")
		return true
	if Input.is_action_just_pressed("attack_heavy"):
		machine.change_to(&"Charge")
		return true
	return false
