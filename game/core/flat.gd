class_name Flat
## Conversión entre el "plano del suelo" (Vector2) y el mundo 3D.
## El juego piensa en 2D sobre el suelo: x = derecha, y = hacia la cámara (abajo en pantalla).
## En 3D eso es el plano XZ: Vector2(x, y) <-> Vector3(x, altura, y). 32 px de arte = 1 m.

## Píxeles de arte por metro. Los sprites usan pixel_size = 1 / PIXELS_PER_METER.
const PIXELS_PER_METER: float = 32.0


## Del suelo al mundo, a la altura `y`.
static func to3(v: Vector2, y: float = 0.0) -> Vector3:
	return Vector3(v.x, y, v.y)


## Del mundo al suelo (ignora la altura).
static func of(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


## Ángulo de giro en Y para que el eje +X local mire hacia `dir` (dirección en el suelo).
static func yaw(dir: Vector2) -> float:
	return -dir.angle()
