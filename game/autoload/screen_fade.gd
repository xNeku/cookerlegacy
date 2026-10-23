extends CanvasLayer
## Autoload "ScreenFade": fundido a negro de pantalla completa, por encima de todo.
## Uso: await ScreenFade.fade_out(0.5) · cambiar de escena · ScreenFade.fade_in(0.5)
## Va en tiempo real (no le afectan el hitstop ni las pausas).

## Color del fundido.
@export var color: Color = Color(0.02, 0.015, 0.04)

@onready var _rect: ColorRect = %Rect

var _tween: Tween


func _ready() -> void:
	_rect.color = color
	_rect.modulate.a = 0.0


## Funde a negro. Devuelve la señal para poder esperarla con await.
func fade_out(time: float = 0.5) -> Signal:
	return _fade_to(1.0, time)


## Vuelve de negro.
func fade_in(time: float = 0.5) -> Signal:
	return _fade_to(0.0, time)


## Pone la pantalla en negro al instante (antes de cambiar de escena).
func set_black() -> void:
	if _tween:
		_tween.kill()
	_rect.modulate.a = 1.0


func is_black() -> bool:
	return _rect.modulate.a >= 0.99


func _fade_to(alpha: float, time: float) -> Signal:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ignore_time_scale(true)
	_tween.tween_property(_rect, "modulate:a", alpha, time)
	return _tween.finished
