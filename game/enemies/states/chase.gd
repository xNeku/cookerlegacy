extends EnemyState
## Persigue. Con `surround_weight` > 0 no va recto: busca su hueco alrededor del
## cocinero (cada uno tiene su ángulo), así un grupo te rodea en vez de ir en fila.
## Cuando está a `attack_range` y puede atacar, pasa al aviso (Windup).

## Distancia (m) a su hueco a partir de la que deja de moverse.
const ARRIVE_DISTANCE: float = 0.1


func enter(_previous: State) -> void:
	enemy.play_animation(&"run", &"idle")


func physics_update(delta: float) -> void:
	var data := enemy.data
	var dist := enemy.distance_to_target()
	if dist > data.lose_range:
		machine.change_to(&"Idle")
		return
	if dist <= data.attack_range and enemy.can_attack():
		machine.change_to(&"Windup")
		return

	enemy.surround_angle += data.surround_spin * delta
	var target_pos := Flat.of(enemy.target.global_position)
	var slot := target_pos + Vector2.from_angle(enemy.surround_angle) * data.surround_radius
	# Lejos va más directo; cerca se reparte en su hueco.
	var point := target_pos.lerp(slot, data.surround_weight)
	if enemy.ground_position.distance_to(point) > ARRIVE_DISTANCE:
		enemy.move_towards(point, delta)
		enemy.play_animation(&"run", &"idle")
	else:
		enemy.apply_friction(delta)
		enemy.face(enemy.direction_to_target())
		enemy.play_animation(&"idle")
	enemy.move_and_slide()
