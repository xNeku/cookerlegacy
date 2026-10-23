extends CanvasLayer
## Post-proceso en pantalla: tilt-shift (desenfoque arriba y abajo) y viñeta.
## Cada nivel puede usar su ajuste: pon aquí otro material (duplica el de game/fx/materials).
## Vacío = el de la escena.

@export var tilt_shift_material: ShaderMaterial
@export var vignette_material: ShaderMaterial


func _ready() -> void:
	if tilt_shift_material:
		$TiltShift.material = tilt_shift_material
	if vignette_material:
		$Vignette.material = vignette_material
