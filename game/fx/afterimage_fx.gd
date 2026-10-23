class_name AfterimageFx
extends Sprite3D
## Fantasma de un frame (estela del dash): copia lo que se ve del sprite, brilla y se apaga.

## Lo que tarda en desaparecer (s).
@export var lifetime: float = 0.22


## Copia el frame actual de `source` con el color `color`. Llamar antes de añadirlo.
func copy_from(source: AnimatedSprite3D, color: Color) -> void:
	var tex := SpriteFX.current_texture(source)
	texture = tex
	flip_h = source.flip_h
	pixel_size = source.pixel_size
	offset = source.offset
	centered = source.centered
	var mat := (material_override as ShaderMaterial).duplicate() as ShaderMaterial
	mat.set_shader_parameter("texture_albedo", (tex as AtlasTexture).atlas if tex is AtlasTexture else tex)
	mat.set_shader_parameter("color", color)
	material_override = mat


func _ready() -> void:
	var mat := material_override as ShaderMaterial
	var tween := create_tween()
	tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("fade", v), 0.8, 0.0, lifetime)
	tween.tween_callback(queue_free)
