class_name SpriteFX
extends Node
## Efectos del sprite de un personaje (cocinero, enemigos, muñecos):
## - le pone el shader de personaje (luces, sombras, mirar a cámara) y le pasa la textura;
## - flash y aplastón al recibir un golpe (si tiene `hurtbox`);
## - tintes que brillan (dash, carga, aviso de ataque).

## El sprite (AnimatedSprite3D o Sprite3D).
@export var sprite: SpriteBase3D
## Material base (character_sprite_material.tres). Se duplica para cada personaje.
@export var material: ShaderMaterial
## Opcional: con ella, flash y aplastón automáticos al recibir cada golpe.
@export var hurtbox: Hurtbox
@export var flash_color: Color = Color.WHITE
## Duración del flash (s).
@export var flash_time: float = 0.1
## Aplastón al recibir el golpe (0 = nada): se ensancha y encoge esta proporción.
@export_range(0.0, 0.5) var squash_amount: float = 0.18
## Duración del aplastón (s).
@export var squash_time: float = 0.14

var _material: ShaderMaterial
var _base_scale: Vector3
var _flash_tween: Tween
var _squash_tween: Tween


func _ready() -> void:
	_material = material.duplicate()
	sprite.material_override = _material
	_base_scale = sprite.scale
	if sprite is AnimatedSprite3D:
		sprite.frame_changed.connect(_bind_texture)
		sprite.animation_changed.connect(_bind_texture)
	elif sprite is Sprite3D:
		sprite.texture_changed.connect(_bind_texture)
	_bind_texture()
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)


## Destello. Sin color, usa `flash_color`.
func flash(color: Color = Color(0, 0, 0, 0), time: float = -1.0) -> void:
	var c := flash_color if color.a == 0.0 else color
	var t := flash_time if time < 0.0 else time
	_material.set_shader_parameter("flash_color", c)
	if _flash_tween:
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_method(_set_flash, 1.0, 0.0, t)


## Aplastón (se ensancha y vuelve con rebote).
func squash(amount: float = -1.0) -> void:
	var a := squash_amount if amount < 0.0 else amount
	if a <= 0.0:
		return
	if _squash_tween:
		_squash_tween.kill()
	sprite.scale = _base_scale * Vector3(1.0 + a, 1.0 - a, 1.0)
	_squash_tween = create_tween()
	_squash_tween.tween_property(sprite, "scale", _base_scale, squash_time) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Tinte que brilla (0 = nada, 1 = máximo).
func set_tint(color: Color, amount: float) -> void:
	_material.set_shader_parameter("tint_color", color)
	_material.set_shader_parameter("tint_amount", amount)


## Textura del frame que se ve ahora (para copiarla: fantasmas, restos...).
static func current_texture(s: SpriteBase3D) -> Texture2D:
	if s is AnimatedSprite3D:
		var anim := s as AnimatedSprite3D
		if anim.sprite_frames and anim.sprite_frames.has_animation(anim.animation):
			return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
		return null
	return (s as Sprite3D).texture


func _on_hit_received(_hitbox: Hitbox) -> void:
	flash()
	squash()


func _set_flash(value: float) -> void:
	_material.set_shader_parameter("flash_amount", value)


func _bind_texture() -> void:
	var tex := current_texture(sprite)
	if tex is AtlasTexture:
		tex = (tex as AtlasTexture).atlas
	_material.set_shader_parameter("texture_albedo", tex)
