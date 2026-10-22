class_name EnemyState
extends State
## Base de los estados de enemigo. Da acceso tipado al Enemy dueño.

var enemy: Enemy:
	get:
		return owner as Enemy
