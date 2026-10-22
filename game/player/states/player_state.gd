class_name PlayerState
extends State
## Base de los estados del cocinero. Da acceso tipado al Player.

## El Player dueño de este estado (la raíz de player.tscn).
var player: Player:
	get:
		return owner as Player
