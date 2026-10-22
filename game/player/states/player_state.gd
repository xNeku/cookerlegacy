class_name PlayerState
extends State
## Base de los estados del cocinero. Da acceso tipado al Player y las
## comprobaciones comunes de acciones. Todas leen del buffer de input del Player,
## así una pulsación un pelín temprana no se pierde.

## El Player dueño de este estado (la raíz de player.tscn).
var player: Player:
	get:
		return owner as Player


## Dash si se ha pulsado y quedan cargas.
func try_dash() -> bool:
	if player.can_dash() and player.consume_action(&"dash"):
		machine.change_to(&"Dash")
		return true
	return false


## Salto si se ha pulsado y está en el suelo.
func try_jump() -> bool:
	if player.can_jump() and player.consume_action(&"jump"):
		player.jump()
		machine.change_to(&"Jump")
		return true
	return false


## Ataques. En el suelo △ empieza a cargar; en el aire sale el golpe fuerte directo
## (el SaltoGolpe de Fase 4 irá aquí).
func try_attack() -> bool:
	if player.consume_action(&"attack_light"):
		machine.change_to(&"LightAttack")
		return true
	if player.consume_action(&"attack_heavy"):
		machine.change_to(&"HeavyAttack" if player.is_airborne() else &"Charge")
		return true
	return false


## Todas las acciones, en orden de prioridad. Para estados libres (Idle, Move, Jump).
func try_start_action() -> bool:
	return try_dash() or try_jump() or try_attack()
