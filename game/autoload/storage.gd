extends Node
## Autoload "Storage": el almacén. Todo lo que dropeas, cosechas o pescas acaba aquí solo.
## También lleva la cuenta de lo conseguido en la noche actual (para el resumen).
## Uso: Storage.add(item, 1) · Storage.count(item) · Storage.night_loot()

## Cada vez que entra algo (cantidad que entra y total que hay ahora).
signal item_added(item: ItemData, amount: int, total: int)

## id → cantidad en el almacén.
var _counts: Dictionary = {}
## id → cantidad conseguida esta noche.
var _night: Dictionary = {}
## id → ItemData (para iconos y nombres).
var _items: Dictionary = {}


func add(item: ItemData, amount: int = 1) -> void:
	_items[item.id] = item
	_counts[item.id] = _counts.get(item.id, 0) + amount
	_night[item.id] = _night.get(item.id, 0) + amount
	item_added.emit(item, amount, _counts[item.id])


func count(item: ItemData) -> int:
	return _counts.get(item.id, 0)


## Todo lo que hay: [{item, amount}].
func get_all() -> Array[Dictionary]:
	return _list(_counts)


## Empieza a contar una noche nueva.
func begin_night() -> void:
	_night.clear()


## Lo conseguido esta noche: [{item, amount}].
func night_loot() -> Array[Dictionary]:
	return _list(_night)


func _list(source: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in source:
		out.append({item = _items[id], amount = source[id]})
	return out
