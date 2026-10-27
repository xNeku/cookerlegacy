extends CanvasLayer
## Panel del almacén: todo lo que hay, con icono y cantidad. Lo abre el almacén
## (grupo "storage_panel": toggle / open / close).

## Fila de item (icono + cantidad).
@export var loot_row_scene: PackedScene

@onready var _panel: Control = %Panel
@onready var _list: Container = %List
@onready var _empty: Label = %Empty

var _open: bool = false


func _ready() -> void:
	add_to_group(&"storage_panel")
	_panel.visible = false


func toggle() -> void:
	if _open:
		close()
	else:
		open()


func open() -> void:
	_open = true
	for child in _list.get_children():
		child.queue_free()
	var items := Storage.get_all()
	for entry in items:
		var row := loot_row_scene.instantiate()
		_list.add_child(row)
		row.setup(entry.item, entry.amount)
	_empty.visible = items.is_empty()
	_panel.visible = true
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(0.85, 0.85)
	_panel.modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.1)


func close() -> void:
	if not _open:
		return
	_open = false
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func() -> void: _panel.visible = false)
