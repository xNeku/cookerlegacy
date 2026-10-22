class_name StateMachine
extends Node
## Ejecuta un estado cada vez. Los estados son sus nodos hijo (State).
## Para añadir un estado: nodo hijo nuevo con un script que extienda State.

## Emitida al cambiar de estado. Útil para debug o para que otros reaccionen.
signal state_changed(from: State, to: State)

## Estado con el que arranca. Si se deja vacío, usa el primer hijo.
@export var initial_state: State

var current: State


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.machine = self
	# Esperamos a que el dueño (Player, enemigo...) esté listo antes del primer enter().
	await owner.ready
	var first: State = initial_state if initial_state else _first_state()
	_switch(first)


func _physics_process(delta: float) -> void:
	if current:
		current.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current:
		current.handle_input(event)


## Cambia al estado hijo con ese nombre de nodo, p. ej. change_to(&"Move").
func change_to(state_name: StringName) -> void:
	var next := get_node_or_null(NodePath(state_name)) as State
	if next == null:
		push_error("StateMachine: no existe el estado '%s'" % state_name)
		return
	if next == current:
		return
	_switch(next)


func _switch(next: State) -> void:
	var previous := current
	if previous:
		previous.exit()
	current = next
	current.enter(previous)
	state_changed.emit(previous, current)


func _first_state() -> State:
	for child in get_children():
		if child is State:
			return child
	return null
