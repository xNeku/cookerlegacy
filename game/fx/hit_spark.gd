extends CPUParticles2D
## Chispas de impacto. Se crean en el punto del golpe, mirando hacia donde va el golpe,
## y se borran solas al acabar.


func _ready() -> void:
	finished.connect(queue_free)
	emitting = true
