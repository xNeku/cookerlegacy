class_name LootRow
extends HBoxContainer
## Una fila de loot: icono y cantidad. La usan el HUD de la noche y el resumen.

@onready var _icon: TextureRect = %Icon
@onready var _amount: Label = %Amount

var item: ItemData


func setup(new_item: ItemData, amount: int) -> void:
	item = new_item
	if not is_node_ready():
		await ready
	_icon.texture = item.icon
	_amount.text = "x%d" % amount
	tooltip_text = item.display_name


## Cambia la cantidad con un saltito.
func bump(amount: int) -> void:
	_amount.text = "x%d" % amount
	pivot_offset = size * 0.5
	scale = Vector2(1.35, 1.35)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
