extends EnemyState
## Quieto hasta que el cocinero entra en su rango de detección.


func enter(_previous: State) -> void:
	enemy.play_animation(&"idle")


func physics_update(delta: float) -> void:
	enemy.apply_friction(delta)
	enemy.move_and_slide()
	if enemy.always_chase or enemy.distance_to_target() <= enemy.data.detect_range:
		machine.change_to(&"Chase")
