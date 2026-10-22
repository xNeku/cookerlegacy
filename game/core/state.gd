class_name State
extends Node
## Un estado de una StateMachine. Cada estado es un nodo hijo de la máquina.
## Se sobreescriben solo las funciones que hagan falta.

## Máquina a la que pertenece. La asigna StateMachine al arrancar.
var machine: StateMachine


## Al entrar en el estado. `previous` es el estado del que venimos (null al arrancar).
func enter(_previous: State) -> void:
	pass


## Al salir del estado.
func exit() -> void:
	pass


## Cada frame de física mientras el estado está activo.
func physics_update(_delta: float) -> void:
	pass


## Input suelto (pulsaciones) mientras el estado está activo.
func handle_input(_event: InputEvent) -> void:
	pass
